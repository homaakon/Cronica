//
//  WatchProvidersList.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 14/01/23.
//

import SwiftUI
import NukeUI

struct WatchProvidersList: View {
    let id: ItemContent.ID
    let type: MediaType
    @State private var isProvidersAvailable = false
    @State private var items = [WatchProviderContent]()
    @State private var link: URL?
    @State private var isLoaded = false
    @AppStorage("firstLocaleCheck") private var firstCheck = false
    @State private var showConfirmation = false
    @StateObject private var settings = SettingsStore.shared
    @AppStorage("alwaysShowConfirmationWatchProvider") private var isConfirmationEnabled = true
    var body: some View {
        VStack {
            if isProvidersAvailable && settings.isWatchProviderEnabled {
                TitleView(title: NSLocalizedString("Where to Watch", comment: ""),
                          subtitle: NSLocalizedString("Provided by JustWatch", comment: ""),
                          showChevron: false)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(items, id: \.self) { item in
                            Button {
                                if isConfirmationEnabled {
                                    showConfirmation.toggle()
                                } else {
                                    openLink()
                                }
                            } label: {
                                providerItemView(item)
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, item.self == items.first.self ? 16 : 0)
                            .padding(.trailing, item.self == items.last.self ? 16 : 0)
                            .padding(.horizontal, 6)
                            .padding(.top, 8)
                            .applyHoverEffect()
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .task { await load(id: id, media: type) }
        .confirmationDialog("This will open TMDb website with the links to each service.",
                            isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("Confirm") { openLink() }
            Button("Confirm and don't ask again") {
                isConfirmationEnabled = false
                openLink()
            }
        }
    }
    
    private func providerItemView(_ item: WatchProviderContent) -> some View {
        VStack(alignment: .leading) {
            LazyImage(url: item.providerImage) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    VStack {
                        ProgressView()
                            .frame(width: DrawingConstants.imageWidth,
                                   height: DrawingConstants.imageHeight)
                    }
                }
            }
            .frame(width: DrawingConstants.imageWidth,
                   height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
            .shadow(radius: 2)
            .applyHoverEffect()
            Text(item.providerTitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(DrawingConstants.lineLimits)
                .padding(.leading, 2)
        }
        .frame(width: DrawingConstants.imageWidth)
        .padding(.vertical, 6)
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let imageWidth: CGFloat = 60
    static let imageHeight: CGFloat = 60
    static let lineLimits: Int = 1
}

#Preview {
    WatchProvidersList(id: ItemContent.example.id, type: .movie)
}

extension WatchProvidersList {
    private func checkLocale() {
        if firstCheck { return }
        let userLocale = Locale.userRegion
        let providerRegions = AppContentRegion.allCases
        for region in providerRegions {
            if userLocale.lowercased() == region.rawValue.lowercased() {
                settings.watchRegion = region
            }
        }
        firstCheck = true
    }
    
    private func openLink() {
        if let link = link {
#if os(macOS)
            NSWorkspace.shared.open(link)
#else
            UIApplication.shared.open(link)
#endif
            CronicaTelemetry.shared.handleMessage("link_opened", for: "watch_provider_link")
        }
    }
    
    @MainActor
    func load(id: ItemContent.ID, media: MediaType) async {
        do {
            if !firstCheck { checkLocale() }
            if Task.isCancelled { return }
            if isLoaded { return }
            let providers = try await NetworkService.shared.fetchProviders(id: id, for: media)
            guard let results = providers.results else { return }
            let regionContent = filterByRegion(results)
            if let regionContent {
                link = regionContent.itemLink
                var content = [WatchProviderContent]()
                if let flatrate = regionContent.flatrate {
                    if settings.isSelectedWatchProviderEnabled {
                        for item in flatrate {
                            if settings.selectedWatchProviders.contains(item.itemID) {
                                content.append(item)
                            }
                        }
                    } else {
                        content.append(contentsOf: flatrate)
                    }
                    
                }
                if let buy =  regionContent.buy {
                    if settings.isSelectedWatchProviderEnabled {
                        for item in buy {
                            if settings.selectedWatchProviders.contains(item.itemID) {
                                content.append(item)
                            }
                        }
                    } else {
                        content.append(contentsOf: buy)
                    }
                    
                }
                
                items.append(contentsOf: content.sorted { $0.listPriority < $1.listPriority })
                
            }
            if !items.isEmpty {
                withAnimation { isProvidersAvailable = true }
            }
            isLoaded = true
        } catch {
            if Task.isCancelled { return }
            let message = """
Can't load the provider for \(id) with media type of \(media.rawValue).
Actual region: \(Locale.userRegion), selected region: \(settings.watchRegion.rawValue).
Error: \(error.localizedDescription)
"""
            CronicaTelemetry.shared.handleMessage(message, for: "watch_provider_failed")
        }
    }
    
    private func filterByRegion(_ results: Results) -> ProviderItem? {
        let regionMapping: [AppContentRegion: ProviderItem?] = [
            .br: results.br,
            .us: results.us,
            .ae: results.ae,
            .ar: results.ar,
            .at: results.at,
            .au: results.au,
            .be: results.be,
            .bg: results.bg,
            .ca: results.ca,
            .ch: results.ch,
            .cz: results.cz,
            .de: results.de,
            .dk: results.dk,
            .ee: results.ee,
            .es: results.es,
            .fi: results.fi,
            .fr: results.fr,
            .gb: results.gb,
            .hk: results.hk,
            .hr: results.hr,
            .hu: results.hu,
            .id: results.id,
            .ie: results.ie,
            .india: results.resultsIN,
            .it: results.it,
            .jp: results.jp,
            .kr: results.kr,
            .lt: results.lt,
            .mx: results.mx,
            .nl: results.nl,
            .no: results.no,
            .nz: results.nz,
            .ph: results.ph,
            .pl: results.pl,
            .pt: results.pt,
            .rs: results.rs,
            .se: results.se,
            .sk: results.sk,
            .tr: results.tr,
            .za: results.za
        ]
        
        return regionMapping[settings.watchRegion] ?? nil
    }
}
