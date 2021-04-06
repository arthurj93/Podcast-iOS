//
//  RSSFeed+Extension.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 02/04/21.
//

import FeedKit

extension RSSFeed {
    func toEpisodes() -> [Episode] {
        let imageUrl = self.iTunes?.iTunesImage?.attributes?.href
        var episodes: [Episode] = .init()
        self.items?.forEach { feedItem in
            var episode: Episode = .init(feedItem: feedItem)
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        }
        return episodes
    }
}
