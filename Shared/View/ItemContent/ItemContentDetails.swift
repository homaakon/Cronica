//
//  ItemContentDetails.swift
//  Cronica
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentDetails: View {
    var title: String
    var id: Int
    var type: MediaType
    @StateObject private var viewModel: ItemContentViewModel
    @StateObject private var store = SettingsStore.shared
    @State private var showPopup = false
    @State private var showSeasonConfirmation = false
    @State private var switchMarkAsView = false
    @State private var showCustomList = false
    @State private var showUserNotes = false
    @State private var popupType: ActionPopupItems?
#if os(macOS)
    var handleToolbarOnPopup: Bool = false
#endif
    init(title: String, id: Int, type: MediaType, handleToolbar: Bool = false) {
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.title = title
        self.id = id
        self.type = type
#if os(macOS)
        self.handleToolbarOnPopup = handleToolbar
#endif
    }
    var body: some View {
        ZStack {
            ScrollView {
#if os(macOS)
                ItemContentPadView(id: id, title: title, type: type,
                                   showCustomList: $showCustomList,
                                   popupType: $popupType, showPopup: $showPopup)
                .environmentObject(viewModel)
                .overlay { if viewModel.isLoading { ProgressView().padding().unredacted() } }
                .toolbar {
                    if handleToolbarOnPopup {
                        ToolbarItem(placement: .status) {
							HStack {
								if viewModel.isInWatchlist {
									favoriteButton
									archiveButton
									pinButton
									userNotesButton
								}
								shareButton
							}
							.disabled(viewModel.isLoading ? true : false)
                        }
                    } else {
                        ToolbarItem {
							HStack {
								if viewModel.isInWatchlist {
									favoriteButton
									archiveButton
									pinButton
									userNotesButton
								}
								shareButton
							}
							.disabled(viewModel.isLoading ? true : false)
                        }
                    }
                }
#elseif os(iOS)
                if UIDevice.isIPad {
                    ItemContentPadView(id: id,
                                       title: title,
                                       type: type,
                                       showCustomList: $showCustomList,
                                       popupType: $popupType,
                                       showPopup: $showPopup)
                    .environmentObject(viewModel)
                    .toolbar {
                        ToolbarItem {
                            HStack {
                                if viewModel.isInWatchlist {
                                    favoriteButton
                                    archiveButton
                                    pinButton
                                    userNotesButton
                                }
                                shareButton
                                moreMenu
                            }
                            .disabled(viewModel.isLoading ? true : false)
                        }
                    }
                } else {
                    ItemContentPhoneView(title: title,
                                         type: type,
                                         id: id,
                                         showPopup: $showPopup,
                                         showCustomList: $showCustomList,
                                         popupType: $popupType,
                                         showReviewSheet: $showUserNotes)
                    .environmentObject(viewModel)
                    .toolbar {
                        ToolbarItem {
                            HStack {
                                shareButton
                                moreMenu
                                
                            }
                            .disabled(viewModel.isLoading ? true : false)
                        }
                    }
                }
#elseif os(tvOS)
                ItemContentTVView(title: title, type: type, id: id)
                    .environmentObject(viewModel)
#endif
            }
            .background {
                TranslucentBackground(image: viewModel.showPoster ? viewModel.content?.posterImageLarge : viewModel.content?.cardImageLarge)
            }
            .task {
                await viewModel.load()
                viewModel.registerNotification()
                viewModel.checkIfAdded()
            }
            .actionPopup(isShowing: $showPopup, for: popupType)
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("Cancel") { }
                Button("Retry") { Task { await viewModel.load() } }
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showCustomList) {
                NavigationStack {
                    if let contentID = viewModel.content?.itemContentID {
                        ItemContentCustomListSelector(contentID: contentID,
                                                      showView: $showCustomList,
                                                      title: title, image: viewModel.content?.cardImageSmall)
                    }
                }
                .onDisappear {
                    viewModel.checkListStatus()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
#if os(macOS)
                .frame(width: 500, height: 600, alignment: .center)
#else
                .appTheme()
                .appTint()
#endif
            }
            .sheet(isPresented: $showUserNotes) {
                if let contentID = viewModel.content?.itemContentID {
                    NavigationStack {
                        ReviewView(id: contentID, showView: $showUserNotes)
                    }
                    .presentationDetents([.large])
#if os(macOS)
                    .frame(width: 500, height: 500, alignment: .center)
#else
                    .appTheme()
                    .appTint()
#endif
                }
            }
            .actionPopup(isShowing: $showPopup, for: popupType)
#if os(tvOS)
            .ignoresSafeArea(.all, edges: .horizontal)
#endif
        }
    }
    
    private var addToCustomListButton: some View {
        Button {
            showCustomList.toggle()
        } label: {
            Label("addToCustomList", systemImage: "rectangle.on.rectangle.angled")
        }
    }
    
    private var watchButton: some View {
        Button {
            viewModel.update(.watched)
            animate(for: viewModel.isWatched ? .markedWatched : .removedWatched)
        } label: {
            Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
        }
#if os(iOS) || os(macOS)
        .keyboardShortcut("w", modifiers: [.option])
#endif
    }
    
    private var favoriteButton: some View {
        Button {
            viewModel.update(.favorite)
            animate(for: viewModel.isFavorite ? .markedFavorite : .removedFavorite)
        } label: {
            Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: viewModel.isFavorite ? "heart.fill" : "heart")
        }
#if os(iOS) || os(macOS)
        .keyboardShortcut("f", modifiers: [.option])
#endif
    }
    
    private var archiveButton: some View {
        Button {
            viewModel.update(.archive)
            animate(for: viewModel.isArchive ? .markedArchive : .removedArchive)
        } label: {
            Label(viewModel.isArchive ? "Remove from Archive" : "Archive Item",
                  systemImage: viewModel.isArchive ? "archivebox.fill" : "archivebox")
        }
    }
    
    private var pinButton: some View {
        Button {
            viewModel.update(.pin)
            animate(for: viewModel.isPin ? .markedPin : .removedPin)
        } label: {
            Label(viewModel.isPin ? "Unpin Item" : "Pin Item",
                  systemImage: viewModel.isPin ? "pin.slash.fill" : "pin.fill")
        }
    }
    
#if os(iOS)
    private var openInMenu: some View {
        Menu {
            if let homepage = viewModel.content?.homepage {
                Button("Official Website") {
                    guard let url = URL(string: homepage) else { return }
                    UIApplication.shared.open(url)
                }
            }
            if viewModel.content?.hasIMDbUrl ?? false {
                Button("IMDb") {
                    guard let url = viewModel.content?.imdbUrl else { return }
                    UIApplication.shared.open(url)
                }
            }
            Button("TMDb") {
                guard let url = viewModel.content?.itemURL else { return }
                UIApplication.shared.open(url)
            }
        } label: {
            if UIDevice.isIPad {
                Label("Open in", systemImage: "ellipsis.circle")
            } else {
                Text("Open in")
            }
        }
    }
#endif
    
#if os(iOS) || os(macOS)
    private var moreMenu: some View {
        Menu {
#if os(iOS)
            if UIDevice.isIPhone {
                if viewModel.isInWatchlist {
					if type == .movie {
						favoriteButton
					} else {
						watchButton
					}
                    archiveButton
                    pinButton
                    userNotesButton
                }
            }
            openInMenu
#endif
        } label: {
            Label("More Options", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
        .disabled(viewModel.isLoading ? true : false)
    }
#endif
    
    private var userNotesButton: some View {
        Button {
            showUserNotes.toggle()
        } label: {
            Label("reviewTitle", systemImage: "note.text")
        }
    }
    
    @ViewBuilder
    private var shareButton: some View {
#if os(iOS) || os(macOS)
        switch store.shareLinkPreference {
        case .tmdb: if let url = viewModel.content?.itemURL { ShareLink(item: url) }
        case .cronica: if let cronicaUrl {
			ShareLink(item: cronicaUrl, message: Text(title))
		}
        }
#endif
    }
    
    private var cronicaUrl: URL? {
        if let item = viewModel.content {
            let encodedTitle = item.itemTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let posterPath = item.posterPath ?? String()
            let encodedPoster = posterPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return URL(string: "https://alexandremadeira.dev/cronica/details?id=\(item.itemContentID)&img=\(encodedPoster ?? String())&title=\(encodedTitle ?? String())")
        }
        return nil
    }
    
    private func animate(for action: ActionPopupItems) {
        popupType = action
        withAnimation { showPopup = true }
    }
}

struct ItemContentDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ItemContentDetails(title: ItemContent.example.itemTitle,
                               id: ItemContent.example.id,
                               type: .movie)
        }
    }
}
