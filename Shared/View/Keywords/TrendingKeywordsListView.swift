//
//  TrendingKeywordsListView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import SwiftUI
import NukeUI

struct TrendingKeywordsListView: View {
    @State private var trendingKeywords = [CombinedKeywords]()
    @State private var isLoading = true
    private let keywords: [CombinedKeywords] = [
        .init(id: 210024, name: NSLocalizedString("Anime", comment: ""), image: nil),
        .init(id: 41645, name: NSLocalizedString("Based on Video-Game", comment: ""), image: nil),
        .init(id: 9715, name: NSLocalizedString("Superhero", comment: ""), image: nil),
        .init(id: 9799, name: NSLocalizedString("Romantic Comedy", comment: ""), image: nil),
        .init(id: 9672, name: NSLocalizedString("Based on true story", comment: ""), image: nil),
        .init(id: 256183, name: NSLocalizedString("Supernatural Horror", comment: ""), image: nil),
        .init(id: 10349, name: NSLocalizedString("Survival", comment: ""), image: nil),
        .init(id: 9882, name: NSLocalizedString("Space", comment: ""), image: nil),
        .init(id: 818, name: NSLocalizedString("Based on novel or book", comment: ""), image: nil),
        .init(id: 9951, name: NSLocalizedString("Alien", comment: ""), image: nil),
        .init(id: 189402, name: NSLocalizedString("Crime Investigation", comment: ""), image: nil)
    ]
    private var service: NetworkService = NetworkService.shared
    var body: some View {
        Section {
            ScrollView {
                LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                    ForEach(trendingKeywords) { keyword in
                        if keyword.image != nil {
                            TrendingCardView(keyword: keyword, isLoading: $isLoading)
#if os(tvOS)
                                .padding(.vertical)
#endif
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
            .task { await load() }
#if os(iOS)
            .redacted(reason: isLoading ? .placeholder : [])
#elseif os(tvOS)
            .ignoresSafeArea(.all, edges: .horizontal)
#endif
        } header: {
            HStack {
                Text("Browse by Themes")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                Spacer()
            }
        }
    }
}

#Preview {
    TrendingKeywordsListView()
}

extension TrendingKeywordsListView {
    private func load() async {
        if trendingKeywords.isEmpty {
            for item in keywords.sorted(by: { $0.name < $1.name}) {
                let itemFromKeyword = try? await service.fetchKeyword(type: .movie,
                                                                      page: 1,
                                                                      keywords: item.id,
                                                                      sortBy: TMDBSortBy.popularity.rawValue)
                var url: URL?
                if let firstItem = itemFromKeyword?.first {
                    url = firstItem.cardImageMedium
                }
                let content: CombinedKeywords = .init(id: item.id, name: item.name, image: url)
                trendingKeywords.append(content)
            }
            withAnimation {
                isLoading = false
            }
        }
    }
}

struct CombinedKeywords: Identifiable, Hashable {
    let id: Int
    let name: String
    let image: URL?
}

private struct TrendingCardView: View {
    let keyword: CombinedKeywords
    @Binding var isLoading: Bool
    var body: some View {
        NavigationLink(value: keyword) {
            LazyImage(url: keyword.image) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                    }
                }
            }
            .overlay {
                ZStack {
                    Rectangle().fill(.black.opacity(0.5))
                    VStack {
                        Spacer()
                        HStack {
                            Text(keyword.name)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
                .frame(width: DrawingConstants.width, height: DrawingConstants.height, alignment: .center)
            }
            .frame(width: DrawingConstants.width, height: DrawingConstants.height, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(radius: 2)
            .buttonStyle(.plain)
        }
#if os(iOS)
        .disabled(isLoading)
#elseif os(tvOS)
        .buttonStyle(.card)
#elseif os(macOS)
        .buttonStyle(.plain)
#endif
        .frame(width: DrawingConstants.width, height: DrawingConstants.height, alignment: .center)
    }
}

private struct DrawingConstants {
#if os(iOS)
    static let columns = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160))]
    static let width: CGFloat = 160
    static let height: CGFloat = 100
#elseif os(tvOS)
    static let columns = [GridItem(.adaptive(minimum: 400))]
    static let width: CGFloat = 400
    static let height: CGFloat = 240
#else
    static let columns = [GridItem(.adaptive(minimum: 240))]
    static let width: CGFloat = 240
    static let height: CGFloat = 140
#endif
}
