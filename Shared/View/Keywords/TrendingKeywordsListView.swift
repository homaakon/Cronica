//
//  TrendingKeywordsListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrendingKeywordsListView: View {
	@EnvironmentObject var viewModel: SearchViewModel
    var body: some View {
		VStack {
			if viewModel.isLoadingTrendingKeywords {
				ProgressView()
			}
			if !viewModel.trendingKeywords.isEmpty {
				TitleView(title: "Trending Keywords")
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack {
						ForEach(viewModel.trendingKeywords) { keyword in
							NavigationLink(value: keyword) {
								WebImage(url: keyword.image)
									.resizable()
									.placeholder {
										ZStack {
											Rectangle().fill(.gray.gradient)
											Image(systemName: "popcorn.fill")
										}
									}
									.aspectRatio(contentMode: .fill)
									.overlay {
										ZStack {
											Rectangle().fill(.black.opacity(0.5))
											Text(keyword.name)
												.foregroundColor(.white)
												.fontDesign(.rounded)
												.font(.headline)
												.fontWeight(.semibold)
												.multilineTextAlignment(.center)
												.lineLimit(2)
												.padding()
										}
									}
									.frame(width: 160, height: 100, alignment: .center)
									.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
									.shadow(radius: 2)
									.padding([.leading, .trailing], 4)
									.padding(.leading, keyword.id == viewModel.trendingKeywords.first!.id ? 16 : 0)
									.padding(.trailing, keyword.id == viewModel.trendingKeywords.last!.id ? 16 : 0)
									.padding(.top, 8)
									.padding(.bottom)
							}
						}
					}
				}
			}
		}
		.redacted(reason: viewModel.isLoadingTrendingKeywords ? .placeholder : [])
    }
}

struct TrendingKeywordsListView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingKeywordsListView()
    }
}
