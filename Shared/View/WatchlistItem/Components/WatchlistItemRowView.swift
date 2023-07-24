//
//  WatchlistItemRowView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemRowView: View {
    let content: WatchlistItem
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    @State private var isPin = false
    @State private var isArchive = false
    @StateObject private var settings = SettingsStore.shared
    @State private var showNote = false
    @State private var showCustomListView = false
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    var body: some View {
        NavigationLink(value: content) {
            HStack {
                image
                    .applyHoverEffect()
#if !os(watchOS)
                    .shadow(radius: 2.5)
#else
                    .padding(.vertical)
#endif
                VStack(alignment: .leading) {
                    HStack {
                        Text(content.itemTitle)
                            .lineLimit(DrawingConstants.textLimit)
                            .fontDesign(.rounded)
                    }
                    HStack {
                        Text(content.itemMedia.title)
                            .fontDesign(.rounded)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(.leading, 2)
#if os(iOS) || os(macOS)
                if isFavorite || content.favorite {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .symbolRenderingMode(.multicolor)
                        .padding(.trailing)
                        .accessibilityHidden(true)
                }
#endif
            }
            .task {
                isWatched = content.isWatched
                isFavorite = content.isFavorite
                isPin = content.isPin
                isArchive = content.isArchive
            }
            .sheet(isPresented: $showNote) {
#if os(iOS) || os(macOS)
                NavigationStack {
                    ReviewView(id: content.itemContentID, showView: $showNote)
                }
                .presentationDetents([.large])
#if os(macOS)
                .frame(width: 400, height: 400, alignment: .center)
#elseif os(iOS)
                .appTheme()
                .appTint()
#endif
#endif
            }
            .sheet(isPresented: $showCustomListView) {
                NavigationStack {
                    ItemContentCustomListSelector(contentID: content.itemContentID,
                                                  showView: $showCustomListView,
                                                  title: content.itemTitle,
                                                  image: content.image)
                }
                .presentationDetents([.large])
#if os(macOS)
                .frame(width: 500, height: 600, alignment: .center)
#else
                .appTheme()
                .appTint()
#endif
            }
            .accessibilityElement(children: .combine)
            .watchlistContextMenu(item: content,
                                  isWatched: $isWatched,
                                  isFavorite: $isFavorite,
                                  isPin: $isPin,
                                  isArchive: $isArchive,
                                  showNote: $showNote,
                                  showCustomList: $showCustomListView,
                                  popupType: $popupType,
                                  showPopup: $showPopup)
        }
    }
    
    private var image: some View {
        ZStack {
            WebImage(url: content.image)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: content.itemMedia == .movie ? "film" : "tv")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
            if isWatched || content.watched {
                Color.black.opacity(0.5)
                Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
            }
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
    }
}

struct WatchlistItemRow_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemRowView(content: .example, showPopup: .constant(false), popupType: .constant(nil))
    }
}

private struct DrawingConstants {
#if os(watchOS)
    static let imageWidth: CGFloat = 70
    static let textLimit: Int = 2
#else
    static let imageWidth: CGFloat = 80
    static let textLimit: Int = 1
#endif
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 8
}