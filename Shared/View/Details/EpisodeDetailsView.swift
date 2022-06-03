//
//  EpisodeDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import SwiftUI

struct EpisodeDetailsView: View {
    @Binding var item: Episode?
    @Binding var dismissView: Bool
    var body: some View {
        NavigationView {
            ScrollView {
                if let item = item {
                    VStack {
                        HeroImage(url: item.itemImageLarge,
                                  title: item.itemTitle)
                            .frame(width: DrawingConstants.imageWidth,
                                   height: DrawingConstants.imageHeight)
                            .cornerRadius(DrawingConstants.imageRadius)
                        
                        OverviewBoxView(overview: item.overview,
                                        title: item.itemTitle,
                                        type: .tvShow)
                            .padding()
                    }
                }
            }
            .navigationTitle(item?.itemTitle ?? "")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Done") {
                        dismissView.toggle()
                    }
                })
            }
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let padImageWidth: CGFloat = 660
    static let padImage: CGFloat = 510
    static let imageRadius: CGFloat = 8
}
