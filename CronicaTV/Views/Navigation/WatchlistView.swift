//
//  WatchlistView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var showFilters = false
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    switch selectedOrder {
                    case .released:
                        Text(selectedOrder.title)
                            .font(.title)
                    case .upcoming:
                        Text(selectedOrder.title)
                            .font(.title)
                    case .production:
                        Text(selectedOrder.title)
                            .font(.title)
                    case .watched:
                        Text(selectedOrder.title)
                            .font(.title)
                    case .favorites:
                        Text(selectedOrder.title)
                            .font(.title)
                    case .pin:
                        Text(selectedOrder.title)
                            .font(.title)
                    }
                    Spacer()
                    Button(action: {
                        showFilters.toggle()
                    }, label: {
                        Label("List Filters",
                              systemImage: "line.3.horizontal.decrease.circle")
                    })
                    .padding()
                }
                switch selectedOrder {
                case .released:
                    WatchlistSection(items: items.filter { $0.isReleased })
                case .upcoming:
                    WatchlistSection(items: items.filter { $0.isUpcoming })
                case .production:
                    WatchlistSection(items: items.filter { $0.isInProduction })
                case .watched:
                    WatchlistSection(items: items.filter { $0.isWatched })
                case .favorites:
                    WatchlistSection(items: items.filter { $0.isFavorite })
                case .pin:
                    WatchlistSection(items: items.filter { $0.isPin })
                }
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentDetails(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
            }
            .sheet(isPresented: $showFilters) {
                VStack {
                    ForEach(DefaultListTypes.allCases) { list in
                        Button(list.title) {
                            selectedOrder = list
                            showFilters.toggle()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}

private struct WatchlistSection: View {
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 360))
    ]
    let items: [WatchlistItem]
    var body: some View {
        if !items.isEmpty {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items) { item in
                    WatchlistItemCard(item: item)
                }
            }
            .padding(.top)
        } else {
            Spacer()
            Text("This list is empty.")
            Spacer()
        }
    }
}
