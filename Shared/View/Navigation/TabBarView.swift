//
//  TabBarView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 01/05/22.
//

import SwiftUI
#if os(iOS) || os(tvOS)
/// A TabBar for switching views, only used on iPhone.
struct TabBarView: View {
    @AppStorage("selectedView") var selectedView: Screens?
    var persistence = PersistenceController.shared
    var body: some View {
        details
#if os(iOS)
            .onAppear {
                let settings = SettingsStore.shared
                if settings.isPreferredLaunchScreenEnabled {
                    selectedView = settings.preferredLaunchScreen
                }
            }
            .appTint()
            .appTheme()
#endif
    }
    
#if os(tvOS)
    private var details: some View {
        TabView {
            NavigationStack { HomeView() }
                .tag(HomeView.tag)
                .tabItem { Label("Home", systemImage: "house") }
                .ignoresSafeArea(.all, edges: .horizontal)
            
            NavigationStack { ExploreView() }
                .tag(ExploreView.tag)
                .tabItem { Label("Explore", systemImage: "popcorn") }
            
            NavigationStack {
                WatchlistView()
                    .environment(\.managedObjectContext, persistence.container.viewContext)
            }
            .tabItem { Label("Watchlist", systemImage: "square.stack") }
            .tag(WatchlistView.tag)
            
            NavigationStack { SearchView() }
                .tabItem { Label("Search", systemImage: "magnifyingglass").labelStyle(.iconOnly) }
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape").labelStyle(.iconOnly)  }
        }
        .ignoresSafeArea(.all, edges: .horizontal)
    }
#endif
    
#if os(iOS)
    private var details: some View {
        TabView(selection: $selectedView) {
            NavigationStack { HomeView() }
                .tag(HomeView.tag)
                .tabItem { Label("Home", systemImage: "house") }
            
            NavigationStack { ExploreView() }
                .tag(ExploreView.tag)
                .tabItem { Label("Explore", systemImage: "popcorn") }
            
            NavigationStack {
                WatchlistView()
                    .environment(\.managedObjectContext, persistence.container.viewContext)
            }
            .tag(WatchlistView.tag)
            .tabItem { Label("Watchlist", systemImage: "square.stack") }
            
            NavigationStack { SearchView() }
                .tag(SearchView.tag)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
            
            if UIDevice.isIPhone {
                SettingsView()
                    .tag(SettingsView.tag)
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
        }
        .appTheme()
    }
#endif
}

#Preview {
    TabBarView()
}
#endif
