//
//  TranslucentBackground.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TranslucentBackground: View {
    var image: URL?
    @AppStorage("disableTranslucentBackground") private var disableTranslucent = false
    var body: some View {
        if !disableTranslucent && image != nil {
            ZStack {
                WebImage(url: image)
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .fill(.background)
                            .ignoresSafeArea()
                            .padding(.zero)
                    }
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .padding(.zero)
                    .transition(.opacity)
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .ignoresSafeArea()
                    .padding(.zero)
            }
        }
    }
}

struct TranslucentBackground_Previews: PreviewProvider {
    static var previews: some View {
        TranslucentBackground()
    }
}
