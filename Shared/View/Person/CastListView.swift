//
//  CastListView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

/// A horizontal list that displays a limited number of
/// cast people in an ItemContent.
struct CastListView: View {
    let credits: [Person]
    var body: some View {
        if !credits.isEmpty {
            VStack(alignment: .leading) {
#if os(tvOS)
                TitleView(title: "Cast & Crew")
#else
                NavigationLink(value: credits) {
                    TitleView(title: "Cast & Crew", showChevron: true)
                }
                .buttonStyle(.plain)
#endif
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(credits.prefix(10), id: \.personListID) { person in
                            PersonCardView(person: person)
                                .padding(.leading, person.id == self.credits.first!.id ? DrawingConstants.padding : 0)
                                .buttonStyle(.plain)
                                .applyHoverEffect()
#if os(tvOS)
                                .padding(.vertical)
#endif
                        }
                    }
                    .padding(.bottom)
                    .padding(.top, 8)
                    .padding(.trailing)
                }
            }
#if os(tvOS)
            .padding()
#endif
        }
    }
}

struct PersonListView_Previews: PreviewProvider {
    static var previews: some View {
        CastListView(credits: Person.example)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 140
    static let profileHeight: CGFloat = 200
    static let shadowRadius: CGFloat = 2
    static let profileRadius: CGFloat = 12
    static let lineLimit: Int = 1
    static let padding: CGFloat = 16
}