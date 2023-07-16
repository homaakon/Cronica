//
//  FavoriteButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct FavoriteButton: View {
    let id: String
    @Binding var isFavorite: Bool
    @Binding var popupConfirmationType: ActionPopupItems?
    @Binding var showConfirmationPopup: Bool
    private let persistence = PersistenceController.shared
    var body: some View {
        Button(action: updateFavorite) {
            Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        }
    }
    
    private func updateFavorite() {
        guard let item = persistence.fetch(for: id) else { return }
        persistence.updateFavorite(for: item)
        withAnimation {
            isFavorite.toggle()
            popupConfirmationType = isFavorite ? .markedFavorite : .removedFavorite
            showConfirmationPopup = true
        }
        HapticManager.shared.successHaptic()
    }
}

struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButton(id: ItemContent.example.itemContentID,
                       isFavorite: .constant(true),
                       popupConfirmationType: .constant(nil),
                       showConfirmationPopup: .constant(false))
    }
}
