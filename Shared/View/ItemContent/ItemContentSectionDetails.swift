//
//  ItemContentSectionDetails.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/11/22.
//

import SwiftUI

struct ItemContentSectionDetails: View {
    let title: String
    let items: [ItemContent]
    @State private var showConfirmation = false
    @State private var settings = SettingsStore.shared
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    if settings.listsDisplayType == .poster {
                        posterStyle
                    } else {
                        cardStyle
                    }
                }
                .navigationTitle(LocalizedStringKey(title))
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
        }
    }
    
    @ViewBuilder
    private var cardStyle: some View {
        LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
            ForEach(items) { item in
                CardFrame(item: item, showConfirmation: $showConfirmation)
                    .buttonStyle(.plain)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var posterStyle: some View {
#if os(iOS)
        LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactColumns : DrawingConstants.columns,
                  spacing: settings.isCompactUI ? 10 : 20) {
            ForEach(items) { item in
                Poster(item: item, addedItemConfirmation: $showConfirmation)
                    .buttonStyle(.plain)
            }
        }.padding(.all, settings.isCompactUI ? 10 : nil)
#elseif os(macOS)
        LazyVGrid(columns: DrawingConstants.posterColumns, spacing: 20) {
            ForEach(items) { item in
                Poster(item: item, addedItemConfirmation: $showConfirmation)
                    .buttonStyle(.plain)
            }
        }
        .padding()
#endif
    }
}

struct ItemContentSectionDetails_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentSectionDetails(title: "Preview Items",
                                  items: ItemContent.examples)
    }
}

private struct DrawingConstants {
#if os(macOS) || os(tvOS)
    static let columns = [GridItem(.adaptive(minimum: 240))]
#else
    static let columns: [GridItem] = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))]
#endif
    static let compactColumns: [GridItem] = [GridItem(.adaptive(minimum: 80))]
#if os(macOS)
    static let posterColumns = [GridItem(.adaptive(minimum: 160))]
    static let cardColumns = [GridItem(.adaptive(minimum: 240))]
#endif
}