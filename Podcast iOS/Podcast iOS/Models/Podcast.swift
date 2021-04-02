//
//  Podcast.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 30/03/21.
//

import Foundation

struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl100: String?
    var trackCount: Int?
    var feedUrl: String?
}
