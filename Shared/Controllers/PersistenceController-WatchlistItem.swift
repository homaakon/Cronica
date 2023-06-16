//
//  PersistenceController-WatchlistItem.swift
//  Story
//
//  Created by Alexandre Madeira on 14/02/23.
//

import Foundation
import CoreData

extension PersistenceController {
    // MARK: Basic CRUD
    /// Creates a new WatchlistItem and saves it.
    /// - Parameter content: The content that is used to populate the new WatchlistItem.
    func save(_ content: ItemContent) {
        if !self.isItemSaved(id: content.itemContentID) {
            let item = WatchlistItem(context: container.viewContext)
            item.contentType = content.itemContentMedia.toInt
            item.title = content.itemTitle
            item.originalTitle = content.originalTitle
            item.id = Int64(content.id)
            item.tmdbID = Int64(content.id)
            item.contentID = content.itemContentID
            item.imdbID = content.imdbId
            item.image = content.cardImageMedium
            item.largeCardImage = content.cardImageLarge
            item.mediumPosterImage = content.posterImageMedium
            item.largePosterImage = content.posterImageLarge
            item.schedule = content.itemStatus.toInt
            item.notify = content.itemCanNotify
            item.lastValuesUpdated = Date()
            item.date = content.itemFallbackDate
            item.formattedDate = content.itemTheatricalString
            if content.itemContentMedia == .tvShow {
                if let episode = content.lastEpisodeToAir?.episodeNumber {
                    item.nextEpisodeNumber = Int64(episode)
                }
                item.upcomingSeason = content.hasUpcomingSeason
                item.nextSeasonNumber = Int64(content.nextEpisodeToAir?.seasonNumber ?? 0)
            }
            save()
        }
    }
    
    func fetch(for id: String) -> WatchlistItem? {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let idPredicate = NSPredicate(format: "contentID == %@", id)
        request.predicate = idPredicate
        let items = try? container.viewContext.fetch(request)
        guard let items else { return nil }
        if !items.isEmpty {
            return items[0]
        }
        return nil
    }
    
    /// Updates a WatchlistItem on Core Data.
    func update(item content: ItemContent) {
        if isItemSaved(id: content.itemContentID) {
            let item = fetch(for: content.itemContentID)
            guard let item else { return }
            if item.title != content.itemTitle {
                item.title = content.itemTitle
            }
            if item.originalTitle != content.originalTitle {
                item.originalTitle = content.originalTitle
            }
            if item.image != content.cardImageMedium {
                item.image = content.cardImageMedium
            }
            if item.largeCardImage != content.cardImageLarge {
                item.largeCardImage = content.cardImageLarge
            }
            if item.mediumPosterImage != content.posterImageMedium {
                item.mediumPosterImage = content.posterImageMedium
            }
            if item.largePosterImage != content.posterImageLarge {
                item.largePosterImage = content.posterImageLarge
            }
            if item.schedule != content.itemStatus.toInt {
                item.schedule = content.itemStatus.toInt
            }
            if item.notify != content.itemCanNotify {
                item.notify = content.itemCanNotify
            }
            if item.formattedDate != content.itemTheatricalString {
                item.formattedDate = content.itemTheatricalString
            }
            if content.itemContentMedia == .tvShow {
                if let episode = content.lastEpisodeToAir {
                    let episodeNumber = Int64(episode.itemEpisodeNumber)
                    if item.lastEpisodeNumber != episodeNumber {
                        item.lastEpisodeNumber = episodeNumber
                    }
                }
                if let episode = content.nextEpisodeToAir {
                    if item.nextEpisodeNumber != Int64(episode.itemEpisodeNumber) {
                        item.nextEpisodeNumber = Int64(episode.itemEpisodeNumber)
                    }
                }
                if item.upcomingSeason != content.hasUpcomingSeason {
                    item.upcomingSeason = content.hasUpcomingSeason
                }
                if let nextSeasonNumber = content.nextEpisodeToAir?.itemSeasonNumber {
                    let season = Int64(nextSeasonNumber)
                    if item.nextSeasonNumber != season {
                        item.nextSeasonNumber = season
                    }
                }
            } else {
                if let date = content.itemFallbackDate {
                    if item.date != date {
                        item.date = date
                    }
                }
            }
            item.lastValuesUpdated = Date()
            save()
        }
    }
    
    /// Deletes a WatchlistItem from Core Data.
    func delete(_ content: WatchlistItem) {
        let viewContext = container.viewContext
        let item = try? viewContext.existingObject(with: content.objectID)
        guard let item else { return }
        let notification = NotificationManager.shared
        notification.removeNotification(identifier: content.itemContentID)
        viewContext.delete(item)
        save()
    }
    
    // MARK: Properties updates
    func updateWatched(for item: WatchlistItem) {
        item.watched.toggle()
        if item.isTvShow {
            item.isWatching.toggle()
        }
        save()
    }
    
    func updateFavorite(for item: WatchlistItem) {
        item.favorite.toggle()
        save()
    }
    
    func updatePin(for item: WatchlistItem) {
        item.isPin.toggle()
        save()
    }
    
    func updateArchive(for item: WatchlistItem) {
        item.isArchive.toggle()
        NotificationManager.shared.removeNotification(identifier: item.itemContentID)
        item.shouldNotify.toggle()
        if item.isTvShow {
            item.isWatching.toggle()
            item.displayOnUpNext.toggle()
        }
        save()
    }
    
    func updateReview(for item: WatchlistItem, rating: Int, notes: String) {
        item.userNotes = notes
        item.userRating = Int64(rating)
        save()
    }
    
    func updateDisplayOnUpNext(for item: WatchlistItem) {
        item.displayOnUpNext.toggle()
        save()
    }
    
    // MARK: Properties read
    func isItemSaved(id: String) -> Bool {
        let viewContext = container.viewContext
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        request.predicate = NSPredicate(format: "contentID == %@", id)
        let numberOfObjects = try? viewContext.count(for: request)
        guard let numberOfObjects else { return false }
        if numberOfObjects > 0 {
            return true
        }
        return false
    }
    
    /// Returns a boolean indicating the status of 'watched' on a given item.
    func isMarkedAsWatched(id: String) -> Bool {
        let item = fetch(for: id)
        guard let item else { return false }
        return item.watched
    }
    
    /// Returns a boolean indicating the status of 'favorite' on a given item.
    func isMarkedAsFavorite(id: String) -> Bool {
        let item = fetch(for: id)
        guard let item else { return false }
        return item.favorite
    }
    
    func isItemPinned(id: String) -> Bool {
        let item = fetch(for: id)
        guard let item else { return false }
        return item.isPin
    }
    
    func isItemArchived(id: String) -> Bool {
        let item = fetch(for: id)
        guard let item else { return false }
        return item.isArchive
    }
    
    // MARK: Episode
    func updateEpisodeList(to item: WatchlistItem, show: Int, episodes: [Episode]) {
        var watched = ""
        for episode in episodes {
            watched.append("-\(episode.id)@\(episode.itemSeasonNumber)")
        }
        item.watchedEpisodes?.append(watched)
        item.isWatching = true
        if let lastWatched = episodes.last {
            item.lastSelectedSeason = Int64(lastWatched.itemSeasonNumber)
            item.lastWatchedEpisode = Int64(lastWatched.id)
        }
        save()
    }
      
    func updateEpisodeList(show: Int, season: Int, episode: Int, nextEpisode: Episode? = nil) {
        let contentId = "\(show)@\(MediaType.tvShow.toInt)"
        if isItemSaved(id: contentId) {
            let item = fetch(for: contentId)
            guard let item else { return }
            if isEpisodeSaved(show: show, season: season, episode: episode) {
                let watched = item.watchedEpisodes?.replacingOccurrences(of: "-\(episode)@\(season)", with: "")
                item.watchedEpisodes = watched
                item.isWatching = true
            } else {
                let watched = "-\(episode)@\(season)"
                item.watchedEpisodes?.append(watched)
                item.isWatching = true
                
                if let nextEpisode {
                    updateUpNext(item, episode: nextEpisode)
                }
                item.lastSelectedSeason = Int64(season)
                item.lastWatchedEpisode = Int64(episode)
                item.displayOnUpNext = true
            }
            save()
        }
    }
    
    func updateWatchedEpisodes(for item: WatchlistItem, with episode: Episode) {
        if isEpisodeSaved(show: item.itemId, season: episode.itemSeasonNumber, episode: episode.id) {
            let watched = item.watchedEpisodes?.replacingOccurrences(of: "-\(episode.id)@\(episode.itemSeasonNumber)",
                                                                     with: "")
            item.watchedEpisodes = watched
        } else {
            let watched = "-\(episode.id)@\(episode.itemSeasonNumber)"
            item.watchedEpisodes?.append(watched)
            item.lastSelectedSeason = Int64(episode.itemSeasonNumber)
            item.lastWatchedEpisode = Int64(episode.id)
        }
        item.isWatching = true
        save()
    }
    
    func removeFromUpNext(_ item: WatchlistItem) {
        item.displayOnUpNext = false
        save()
    }
    
    func updateUpNext(_ item: WatchlistItem, episode: Episode) {
        item.nextEpisodeNumberUpNext = Int64(episode.itemEpisodeNumber)
        item.seasonNumberUpNext = Int64(episode.itemSeasonNumber)
        item.displayOnUpNext = true
        save()
    }
    
    func removeWatchedEpisodes(for item: WatchlistItem) {
        item.watchedEpisodes = String()
        item.displayOnUpNext = false
        item.isWatching = false
        save()
    }
    
    func getLastSelectedSeason(_ id: String) -> Int? {
        let item = fetch(for: id)
        guard let item else { return nil }
        if item.lastSelectedSeason == 0 { return 1 }
        return Int(item.lastSelectedSeason)
    }
    
    func fetchLastWatchedEpisode(for id: Int) -> Int? {
        let contentId = "\(id)@\(MediaType.tvShow.toInt)"
        let item = fetch(for: contentId)
        guard let item else { return nil }
        if !item.isWatching { return nil }
        if item.lastWatchedEpisode == 0 { return nil }
        return Int(item.lastWatchedEpisode)
    }
    
    func isEpisodeSaved(show: Int, season: Int, episode: Int) -> Bool {
        let contentId = "\(show)@\(MediaType.tvShow.toInt)"
        if isItemSaved(id: contentId) {
            let item = fetch(for: contentId)
            guard let item, let watched = item.watchedEpisodes else { return false }
            if watched.contains("-\(episode)@\(season)") { return true }
        }
        return false
    }
}
