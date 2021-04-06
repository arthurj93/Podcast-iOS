//
//  UserDefaults+Extension.swift
//  Podcast iOS
//
//  Created by Arthur Jatoba on 06/04/21.
//

import Foundation

extension UserDefaults {
    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadedEpisodesKey = "downloadedEpisodesKey"
    
    func savedPodcasts() -> [Podcast] {
        
        do {
            guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
            guard let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastsData) as? [Podcast] else { return [] }
            return savedPodcasts
        } catch let saveError {
            print("Error while trying to save podcasts:", saveError)
            return []
        }
    }
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcasts()
        let filteredPodcasts = podcasts.filter { p in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
        } catch let saveError {
            print("Error while trying to save podcasts:", saveError)
        }
    }
    
    func downloadEpisode(episode: Episode) {
        do {
            var episodes = downloadedEpisodes()
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encoderError {
            print("Failed while encoder:", encoderError)
        }
    }

    func downloadedEpisodes() -> [Episode] {
        guard let episodesData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            return episodes
        } catch let decoderError {
            print("Failed while decoder:", decoderError)
        }
        return []
    }
    
    func deleteEpisode(episode: Episode) {
            let savedEpisodes = downloadedEpisodes()
            let filteredEpisodes = savedEpisodes.filter { (e) -> Bool in
                return e.title != episode.title
            }
            do {
                let data = try JSONEncoder().encode(filteredEpisodes)
                UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
            } catch let encodeErr {
                print("Failed to encode episode:", encodeErr)
            }
        }
}
