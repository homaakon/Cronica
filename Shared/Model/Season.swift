//
//  Season.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import Foundation
import SwiftUI

struct Season: Codable, Identifiable, Hashable {
    let id, seasonNumber: Int
    let episodes: [Episode]?
    let airDate: String?
}
struct Episode: Identifiable, Codable, Hashable {
    let id: Int
    let episodeNumber, seasonNumber: Int?
    let name, overview, stillPath, airDate: String?
    let crew, guestStars: [Person]?
}
