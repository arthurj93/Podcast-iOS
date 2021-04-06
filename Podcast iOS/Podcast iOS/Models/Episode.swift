//
//  Episode.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 31/03/21.
//

import Foundation
import FeedKit

struct Episode: Codable {
    var title: String
    let pubDate: Date
    let description: String
    var author: String
    let streamUrl: String
    var fileUrl: String?
    var imageUrl: String?

    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
    }
}

enum ChangeEpisode: Int {
    case foward = 1
    case backward = -1
}
