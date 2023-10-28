//
//  InformationContainerView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct InformationContainerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            InformationContainerItem(title: "Your Watchlist", subTitle: "Add everything you want, the Watchlist automatically organizes it for you.", imageName: "rectangle.stack.fill", imageTint: .purple)
            
            InformationContainerItem(title: "Always Synced",
                                     subTitle: "Your Watchlist is always in sync with your Apple Watch, iPad, Mac, and Apple TV.",
                                     imageName: "icloud.fill")
            
            InformationContainerItem(title: "Track your episodes",
                                     subTitle: "Keep track of every episode you've watched.",
                                     imageName: "rectangle.fill.badge.checkmark",
                                     imageTint: .green)
            
            InformationContainerItem(title: "Never miss out", subTitle: "Get notifications about the newest releases.", imageName: "bell.fill", imageTint: .orange)
            
        }
    }
}

struct InformationContainerView_Previews: PreviewProvider {
    static var previews: some View {
        InformationContainerView()
    }
}
