//
//  TrailerListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrailerListView: View {
    var trailers: [VideoItem]?
    @State var selectedItem: VideoItem? = nil
    var body: some View {
        if let trailers {
            VStack {
                Divider().padding(.horizontal)
                HStack {
                    Text("Trailers")
                        .font(.title3)
                        .padding([.horizontal, .top])
                    Spacer()
                }
                .unredacted()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(trailers) { trailer in
                            TrailerItemView(trailer: trailer)
                                .onTapGesture {
                                    selectedItem = trailer
                                }
                                .padding(.horizontal, 4)
                                .padding(.leading, trailer.id == self.trailers?.first!.id ? 16 : 0)
                                .padding(.trailing, trailer.id == self.trailers?.last!.id ? 16 : 0)
                        }
                    }
                    .padding(.top, 8)
                }
                Divider().padding(.horizontal)
            }
            .sheet(item: $selectedItem) { item in
                if let url = item.url {
                    SFSafariViewWrapper(url: url)
                }
            }
        }
    }
}