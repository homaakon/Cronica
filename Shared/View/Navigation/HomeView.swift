//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 10/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    static let tag: Screens? = .home
    @AppStorage("showOnboarding") private var displayOnboard = true
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var settings: SettingsStore
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showConfirmation = false
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
        _settings = StateObject(wrappedValue: SettingsStore())
    }
    var body: some View {
        ZStack {
            if !viewModel.isLoaded {
                ProgressView("Loading")
                    .unredacted()
            }
            VStack {
                ScrollView {
                    UpcomingWatchlist()
                    PinItemsList()
                    ItemContentListView(items: viewModel.trending,
                                        title: "Trending",
                                        subtitle: "Today",
                                        image: "crown",
                                        addedItemConfirmation: $showConfirmation)
                    ForEach(viewModel.sections) { section in
                        ItemContentListView(items: section.results,
                                            title: section.title,
                                            subtitle: section.subtitle,
                                            image: section.image,
                                            addedItemConfirmation: $showConfirmation,
                                            endpoint: section.endpoint)
                    }
                    AttributionView()
                }
                .refreshable { viewModel.reload() }
            }
            .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
                ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
#else
                ItemContentDetails(title: item.itemTitle,
                                   id: item.id,
                                   type: item.itemContentMedia)
#endif
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .navigationDestination(for: WatchlistItem.self) { item in
#if os(macOS)
                ItemContentDetailsView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
#else
                ItemContentDetails(title: item.itemTitle,
                                   id: item.itemId,
                                   type: item.itemMedia)
#endif
            }
            .navigationDestination(for: [WatchlistItem].self) { item in
                TitleWatchlistDetails(items: item)
            }
            .navigationDestination(for: Endpoints.self) { endpoint in
                EndpointDetails(title: endpoint.title,
                                 endpoint: endpoint,
                                 columns: DrawingConstants.columns)
            }
            .navigationDestination(for: [String:[WatchlistItem]].self) { item in
                let keys = item.map { (key, value) in key }
                let value = item.map { (key, value) in value }
                TitleWatchlistDetails(title: keys[0], items: value[0])
            }
            .navigationDestination(for: [String:[ItemContent]].self, destination: { item in
                let keys = item.map { (key, value) in key }
                let value = item.map { (key, value) in value }
                ItemContentCollectionDetails(title: keys[0], items: value[0])
            })
            .redacted(reason: !viewModel.isLoaded ? .placeholder : [] )
            .navigationTitle("Home")
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNotifications.toggle()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                }
#else
                if UIDevice.isIPhone {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {
                                showNotifications.toggle()
                            }, label: {
                                Label("Notifications",
                                      systemImage: "bell")
                            })
                            
                            Button(action: {
                                showSettings.toggle()
                            }, label: {
                                Label("Settings", systemImage: "gearshape")
                            })
                        }
                    }
                }
#endif
            }
            .sheet(isPresented: $displayOnboard) {
                WelcomeView()
#if os(macOS)
                    .frame(width: 500, height: 700, alignment: .center)
#endif
            }
            .sheet(isPresented: $showSettings) {
#if os(iOS)
                SettingsView(showSettings: $showSettings)
                    .environmentObject(settings)
#endif
            }
            .sheet(isPresented: $showNotifications) {
                NotificationListView(showNotification: $showNotifications)
#if os(macOS)
                    .frame(width: 800, height: 500)
#endif
            }
            .task {
                await viewModel.load()
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct TitleWatchlistDetails: View {
    var title = "Upcoming"
    let items: [WatchlistItem]
    @State private var query = ""
    var body: some View {
        List(items) { item in
            WatchlistItemView(content: item)
        }
        .navigationTitle(LocalizedStringKey(title))
        .searchable(text: $query)
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let columns = [GridItem(.adaptive(minimum: 160))]
#else
    static let columns: [GridItem] = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))]
#endif
}
