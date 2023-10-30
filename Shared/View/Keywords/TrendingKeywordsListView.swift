//
//  TrendingKeywordsListView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrendingKeywordsListView: View {
    @State private var trendingKeywords = [CombinedKeywords]()
    @State private var isLoading = true
#if os(tvOS)
    private let columns = [GridItem(.adaptive(minimum: 400))]
#else
    private let columns = [GridItem(.adaptive(minimum: 160))]
#endif
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
#if os(tvOS)
        cardGrid
#else
        VStack {
            if !trendingKeywords.isEmpty {
                TitleView(title: "Trending Keywords").unredacted()
            }
            cardGrid
        }
#endif
    }
    
    private var cardGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(trendingKeywords) { keyword in
                    if keyword.image != nil {
                        trendingCard(keyword)
#if os(tvOS)
                            .padding(.vertical)
#endif
                    }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .task { await load() }
        .redacted(reason: isLoading ? .placeholder : [])
#if os(tvOS)
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
    }
    
    private func trendingCard(_ keyword: CombinedKeywords) -> some View {
        NavigationLink(value: keyword) {
            WebImage(url: keyword.image, options: [.continueInBackground, .highPriority])
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                    }
                }
                .aspectRatio(contentMode: .fill)
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
                                    .lineLimit(2)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
#if os(tvOS)
                    .frame(width: 400, height: 240, alignment: .center)
#else
                    .frame(width: 160, height: 100, alignment: .center)
#endif
                }
#if os(tvOS)
                .frame(width: 400, height: 240, alignment: .center)
#else
                .frame(width: 160, height: 100, alignment: .center)
#endif
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(radius: 2)
                .buttonStyle(.plain)
        }
        .disabled(isLoading)
#if os(tvOS)
        .buttonStyle(.card)
        .frame(width: 400, height: 240, alignment: .center)
#else
        .frame(width: 160, height: 100, alignment: .center)
#endif
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
