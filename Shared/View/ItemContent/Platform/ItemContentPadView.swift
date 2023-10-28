//
//  ItemContentPadView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 18/05/23.
//

import SwiftUI
import SDWebImageSwiftUI
#if !os(tvOS)
/// The Details view for ItemContent for iPadOS and macOS, built with larger screen in mind.
struct ItemContentPadView: View {
    let id: Int
    let title: String
    let type: MediaType
    @Binding var showCustomList: Bool
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var animationImage = ""
    @State private var animateGesture = false
    @State private var showOverview = false
    @State private var showInfoBox = false
    @State private var showReleaseDateInfo = false
    @State private var isSideInfoPanelShowed = false
    @Binding var popupType: ActionPopupItems?
    @StateObject private var store = SettingsStore.shared
    @Binding var showPopup: Bool
    var body: some View {
        VStack {
            header.padding(.leading)
            
            if let seasons = viewModel.content?.itemSeasons {
                SeasonList(showID: id, showTitle: title,
                           numberOfSeasons: seasons, isInWatchlist: $viewModel.isInWatchlist, showCover: viewModel.content?.cardImageMedium).padding(0)
            }
            
            TrailerListView(trailers: viewModel.trailers)
            
            WatchProvidersList(id: id, type: type)
            
            CastListView(credits: viewModel.credits)
            
            HorizontalItemContentListView(items: viewModel.recommendations,
                                          title: "Recommendations",
                                          showPopup: $showPopup,
                                          popupType: $popupType,
                                          displayAsCard: true)
            if showInfoBox {
                GroupBox("Information") {
                    QuickInformationView(item: viewModel.content, showReleaseDateInfo: $showReleaseDateInfo)
                } 
                .padding()
                
            }
            
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#elseif os(macOS)
        .navigationTitle(title)
#endif
        .task {
            if !isSideInfoPanelShowed && !showInfoBox { showInfoBox = true }
        }
    }
    
    private var header: some View {
        HStack {
            WebImage(url: viewModel.content?.posterImageLarge)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "popcorn.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                        .padding()
                    }
                }
                .overlay {
                    ZStack {
                        Rectangle().fill(.thinMaterial)
                        Image(systemName: animationImage)
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                            .scaleEffect(animateGesture ? 1.1 : 1)
                    }
                    .opacity(animateGesture ? 1 : 0)
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 460)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .onTapGesture(count: 2) {
                    animate(for: store.gesture)
                    viewModel.update(store.gesture)
                }
                .shadow(radius: 5)
                .padding()
                .accessibility(hidden: true)
            
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding(.bottom)
                HStack {
                    Text(viewModel.content?.itemOverview ?? "")
                        .lineLimit(10)
                        .onTapGesture {
                            showOverview.toggle()
                        }
                    Spacer()
                }
                .frame(maxWidth: 460)
                .padding(.bottom)
#if os(iOS) || os(macOS)
                .popover(isPresented: $showOverview) {
                    if let overview = viewModel.content?.itemOverview {
                        VStack {
                            ScrollView {
                                Text(overview)
                                    .padding()
                            }
                        }
                        .frame(minWidth: 200, maxWidth: 400, minHeight: 200, maxHeight: 300, alignment: .center)
                    }
                }
#endif
                
                // Actions
                HStack {
                    DetailWatchlistButton(showCustomList: $showCustomList)
                        .environmentObject(viewModel)
                    
                    if viewModel.isInWatchlist {
                        if type == .movie {
                            watchButton
                        } else {
                            favoriteButton
                        }
						
                        Button {
                            showCustomList.toggle()
                        } label: {
#if os(macOS)
                            Label("Lists", systemImage: "rectangle.on.rectangle.angled")
#else
                            VStack {
                                Image(systemName: "rectangle.on.rectangle.angled")
                                Text("Lists")
                                    .padding(.top, 2)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 4)
                            .frame(width: 60)
#endif
                        }
#if os(macOS)
                        .controlSize(.large)
#else
                        .controlSize(.small)
#endif
                        .buttonStyle(.bordered)
#if os(iOS)
                        .buttonBorderShape(.roundedRectangle(radius: 12))
#endif
                        .tint(.primary)
                        .applyHoverEffect()
                        .padding(.leading)
                    }
                }
            }
            .frame(width: 360)
            
            ViewThatFits {
                QuickInformationView(item: viewModel.content, showReleaseDateInfo: $showReleaseDateInfo)
                    .frame(width: 280)
                    .padding(.horizontal)
                    .onAppear {
                        showInfoBox = false
                        isSideInfoPanelShowed = true
                    }
                    .onDisappear {
                        showInfoBox = true
                        isSideInfoPanelShowed = false
                    }
                VStack {
                    Text("")
                }
            }
            
            Spacer()
        }
    }
    
    private var watchButton: some View {
        Button {
            viewModel.update(.watched)
            popupType = viewModel.isWatched ? .markedWatched : .removedWatched
            withAnimation { showPopup = true }
        } label: {
#if os(macOS)
            Label("Watched",
                  systemImage: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
                .symbolEffect(viewModel.isWatched ? .bounce.down : .bounce.up,
                              value: viewModel.isWatched)
#else
            VStack {
                if #available(iOS 17, *) {
                    Image(systemName: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
                        .symbolEffect(viewModel.isWatched ? .bounce.down : .bounce.up,
                                      value: viewModel.isWatched)
                } else {
                    Image(systemName: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
                }
                Text("Watched")
                    .padding(.top, 2)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            .frame(width: 60)
#endif
        }
        .keyboardShortcut("w", modifiers: [.option])
#if os(macOS)
        .controlSize(.large)
#else
        .controlSize(.small)
#endif
        .buttonStyle(.bordered)
#if os(iOS)
        .buttonBorderShape(.roundedRectangle(radius: 12))
#endif
        .tint(.primary)
        .applyHoverEffect()
        .padding(.leading)
    }
    
    private var favoriteButton: some View {
        Button {
            viewModel.update(.favorite)
            popupType = viewModel.isFavorite ? .markedFavorite : .removedFavorite
            withAnimation { showPopup = true }
        } label: {
#if os(macOS)
            Label("Favorite",
                  systemImage: viewModel.isFavorite ? "heart.fill" : "heart")
                .symbolEffect(viewModel.isFavorite ? .bounce.down : .bounce.up,
                              value: viewModel.isFavorite)
#else
            VStack {
                if #available(iOS 17, *) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .symbolEffect(viewModel.isFavorite ? .bounce.down : .bounce.up,
                                      value: viewModel.isFavorite)
                } else {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                }
                Text("Favorite")
                    .padding(.top, 2)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            .frame(width: 60)
#endif
        }
        .keyboardShortcut("w", modifiers: [.option])
#if os(macOS)
        .controlSize(.large)
#else
        .controlSize(.small)
#endif
        .buttonStyle(.bordered)
#if os(iOS)
        .buttonBorderShape(.roundedRectangle(radius: 12))
#endif
        .tint(.primary)
        .applyHoverEffect()
        .padding(.leading)
    }
    
    private func animate(for type: UpdateItemProperties) {
        switch type {
        case .watched: animationImage = viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle"
        case .favorite: animationImage = viewModel.isFavorite ? "heart.slash.fill" : "heart.fill"
        case .pin: animationImage = viewModel.isPin ? "pin.slash" : "pin.fill"
        case .archive: animationImage = viewModel.isArchive ? "archivebox" : "archivebox.fill"
        }
        withAnimation { animateGesture.toggle() }
        HapticManager.shared.successHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { animateGesture = false }
        }
    }
}
#endif
struct QuickInformationView: View {
    let item: ItemContent?
    @Binding var showReleaseDateInfo: Bool
    var body: some View {
        VStack(alignment: .leading) {
            infoView(title: NSLocalizedString("Original Title",
                                              comment: ""),
                     content: item?.originalItemTitle)
            infoView(title: NSLocalizedString("Run Time", comment: ""),
                     content: item?.itemRuntime)
            if let numberOfSeasons = item?.numberOfSeasons, let numberOfEpisodes = item?.numberOfEpisodes {
                infoView(title: NSLocalizedString("Overview",
                                                  comment: ""),
                         content: "\(numberOfSeasons) Seasons • \(numberOfEpisodes) Episodes")
            }
            if item?.itemContentMedia == .movie {
                if let theatricalStringDate = item?.itemTheatricalString {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Release Date")
                                    .font(.caption)
#if !os(tvOS)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
#endif
                            }
                            Text(theatricalStringDate)
                                .lineLimit(1)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                    .padding([.horizontal, .top], 2)
                    .onTapGesture {
                        showReleaseDateInfo.toggle()
                    }
                }
                
            } else {
                infoView(title: NSLocalizedString("First Air Date",
                                                  comment: ""),
                         content: item?.itemFirstAirDate)
            }
            infoView(title: NSLocalizedString("Region of Origin",
                                              comment: ""),
                     content: item?.itemCountry)
            infoView(title: NSLocalizedString("Genres", comment: ""),
                     content: item?.itemGenres)
            if let companies = item?.itemCompanies, let company = item?.itemCompany {
                if !companies.isEmpty {
                    NavigationLink(value: companies) {
                        companiesLabel(company: company)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                infoView(title: NSLocalizedString("Production Company",
                                                  comment: ""),
                         content: item?.itemCompany)
            }
            infoView(title: NSLocalizedString("Status",
                                              comment: ""),
                     content: item?.itemStatus.localizedTitle)
        }
        .sheet(isPresented: $showReleaseDateInfo) {
			let productionRegion = item?.productionCountries?.first?.iso31661 ?? "US"
            DetailedReleaseDateView(item: item?.releaseDates?.results, productionRegion: productionRegion,
                                    dismiss: $showReleaseDateInfo)
#if os(macOS)
            .frame(width: 400, height: 300, alignment: .center)
#else
            .appTint()
            .appTheme()
#endif
        }
    }
    
    private func companiesLabel(company: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Production Companies")
                        .font(.caption)
#if !os(tvOS)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
#endif
                }
                Text(company)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            Spacer()
        }
        .padding([.horizontal, .top], 2)
    }
    
    @ViewBuilder
    private func infoView(title: String, content: String?) -> some View {
        if let content {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.caption)
                    Text(content)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                Spacer()
            }
            .padding([.horizontal, .top], 2)
        } else {
            EmptyView()
        }
    }
}

