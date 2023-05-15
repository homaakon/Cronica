//
//  View-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

extension View {
    func watchlistContextMenu(item: WatchlistItem,
                              isWatched: Binding<Bool>,
                              isFavorite: Binding<Bool>,
                              isPin: Binding<Bool>,
                              isArchive: Binding<Bool>,
                              showNote: Binding<Bool>,
                              showCustomList: Binding<Bool>) -> some View {
        modifier(WatchlistItemContextMenu(item: item,
                                          isWatched: isWatched,
                                          isFavorite: isFavorite,
                                          isPin: isPin,
                                          isArchive: isArchive,
                                          showNote: showNote,
                                          showCustomListView: showCustomList))
    }
    
    func itemContentContextMenu(item: ItemContent,
                                isWatched: Binding<Bool>,
                                showConfirmation: Binding<Bool>,
                                isInWatchlist: Binding<Bool>,
                                showNote: Binding<Bool>,
                                showCustomList: Binding<Bool>) -> some View {
        modifier(ItemContentContextMenu(item: item,
                                        showConfirmation: showConfirmation,
                                        isInWatchlist: isInWatchlist,
                                        isWatched: isWatched,
                                        showNote: showNote,
                                        showCustomListView: showCustomList))
    }
    
    func applyHoverEffect() -> some View {
        modifier(HoverEffectModifier())
    }
    
    func appTheme() -> some View {
        modifier(AppThemeModifier())
    }
    
    func appTint() -> some View {
        modifier(AppTintModifier())
    }
}
