//
//  WatchEpisodeButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 15/08/22.
//

import SwiftUI

struct WatchEpisodeButton: View {
    let episode: Episode
    let season: Int
    let show: Int
    @Binding var isWatched: Bool
    private let persistence = PersistenceController.shared
    private let network = NetworkService.shared
    @State private var isItemSaved = false
    var body: some View {
        Button(action: update) {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "rectangle.fill.badge.minus" : "rectangle.fill.badge.checkmark")
#if os(tvOS)
            .padding()
            .labelStyle(.iconOnly)
#endif
        }
#if os(watchOS)
        .buttonStyle(.borderedProminent)
        .tint(isWatched ? .orange : .green)
#endif
    }
    
    private func update() {
        checkIfItemIsSaved()
        if !isItemSaved {
            Task {
                await fetch()
                handleList()
            }
        } else {
            handleList()
        }
    }
    
    private func checkIfItemIsSaved() {
        let contentId = "\(show)@\(MediaType.tvShow.toInt)"
        let isShowSaved = persistence.isItemSaved(id: contentId)
        isItemSaved = isShowSaved
    }
    
    private func handleList() {
        let contentId = "\(show)@\(MediaType.tvShow.toInt)"
        let item = persistence.fetch(for: contentId)
        guard let item else { return }
        persistence.updateWatchedEpisodes(for: item, with: episode)
        DispatchQueue.main.async {
            withAnimation { isWatched.toggle() }
        }
        HapticManager.shared.successHaptic()
        Task {
            let nextEpisode = await fetchNextEpisode()
            guard let nextEpisode else { return }
            persistence.updateUpNext(item, episode: nextEpisode)
        }
    }
    
    private func fetch() async {
        let content = try? await network.fetchItem(id: show, type: .tvShow)
        guard let content else { return }
        persistence.save(content)
        if content.itemCanNotify && content.itemFallbackDate.isLessThanTwoWeeksAway() {
            NotificationManager.shared.schedule(content)
        }
        isItemSaved = true
    }
    
    private func fetchNextEpisode() async -> Episode? {
        let episode = await EpisodeHelper().fetchNextEpisode(for: self.episode, show: show)
        return episode
    }
}
