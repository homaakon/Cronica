//
//  CoverImageView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//
import SwiftUI
import SDWebImageSwiftUI

#if os(iOS)
struct CoverImageView: View {
    @StateObject private var store = SettingsStore.shared
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var isPad = UIDevice.isIPad
    @State private var animateGesture = false
    @Binding var isFavorite: Bool
    @Binding var isWatched: Bool
    @Binding var isPin: Bool
    @Binding var isArchive: Bool
    let title: String
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var animationImage = ""
    @State private var isAdult = false
    var body: some View {
        VStack {
            HeroImage(url: viewModel.content?.cardImageLarge,
                      title: title,
                      blurImage: isAdult)
            .overlay {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    Image(systemName: animationImage)
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120, alignment: .center)
                        .scaleEffect(animateGesture ? 1.1 : 1)
                }
                .opacity(animateGesture ? 1 : 0)
            }
            .frame(width: (horizontalSizeClass == .regular) ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
                   height: (horizontalSizeClass == .compact) ? DrawingConstants.imageHeight : DrawingConstants.padImageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
            .shadow(radius: DrawingConstants.shadowRadius)
            .padding([.top, .bottom])
            .accessibilityElement(children: .combine)
            .accessibility(hidden: true)
            .onTapGesture(count: 2) {
                animate(for: store.gesture)
                viewModel.update(store.gesture)
            }
            .task {
                isFavorite = viewModel.isFavorite
                isWatched = viewModel.isWatched
            }
            .onAppear {
                guard let isAdult = viewModel.content?.itemIsAdult else { return }
                self.isAdult = isAdult
            }
            
            if let info = viewModel.content?.itemInfo {
                Text(info)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func animate(for type: UpdateItemProperties) {
        switch type {
        case .watched: animationImage = isWatched ? "minus.circle.fill" : "checkmark.circle"
        case .favorite: animationImage = isFavorite ? "heart.slash.fill" : "heart.fill"
        case .pin: animationImage = isPin ? "pin.slash" : "pin"
        case .archive: animationImage = isArchive ? "archivebox.fill" : "archivebox"
        }
        withAnimation { animateGesture.toggle() }
        HapticManager.shared.successHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { animateGesture = false }
        }
    }
}
#endif

private struct DrawingConstants {
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 500
    static let padImageHeight: CGFloat = 300
    static let padImageRadius: CGFloat = 12
}
