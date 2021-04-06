//
//  APIService.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 31/03/21.
//

import Foundation
import Alamofire
import FeedKit

class APIService {

    typealias EpisodeDownloadCompleteTuble = (fileUrl: String, episodeTitle: String)
    static let shared = APIService()
    
    let baseURL = "https://itunes.apple.com/search"
    
    func fetchPodcast(searchText: String, completionHandler: @escaping (Result<[Podcast], Error>) -> ()) {
        let parameters = ["term": searchText, "media": "podcast"]
        let request = AF.request(baseURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
        request.responseData(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                    completionHandler(.success(searchResult.results))
                } catch let decodeError {
                    completionHandler(.failure(decodeError))
                }
            case .failure(let apiError):
                completionHandler(.failure(apiError))
            }
        })
    }

    func fetchEpisodes(feedUrl: String, completion: @escaping ([Episode]) -> ()) {
        guard let url = URL(string: feedUrl) else { return }

        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            parser.parseAsync { result in
                switch result {
                case .success(let feed):
                    guard let feed = feed.rssFeed else { return }
                    completion(feed.toEpisodes())
                case .failure(let parseError):
                    print("Failed to parse feed:", parseError)
                }
            }
        }
    }
    
    func downloadEpisode(episode: Episode) {
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        let progressQueue = DispatchQueue(label: "com.alamofire.progressQueue", qos: .utility)

        AF.download(episode.streamUrl, to: downloadRequest)
            .downloadProgress(queue: progressQueue) { progress in
                print("Download Progress: \(progress.fractionCompleted)")
                
                NotificationCenter.default.post(
                    name: .downloadProgress,
                    object: nil,
                    userInfo: ["title": episode.title, "progress": progress.fractionCompleted]
                )
            }
            .responseData { response in
                let episodeDownloadComplete = EpisodeDownloadCompleteTuble(fileUrl: response.fileURL?.absoluteString ?? "", episode.title)
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
                guard let index = downloadedEpisodes.firstIndex(where: {$0.title == episode.title && $0.author == episode.author}) else { return }
                downloadedEpisodes[index].fileUrl = response.fileURL?.absoluteString
                do {
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    UserDefaults.standard.setValue(data, forKey: UserDefaults.downloadedEpisodesKey)
                } catch let err {
                    print("Failed to encode downloaded episodes with file url update:", err)
                }
            }
    }
    
}

extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}
