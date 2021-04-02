//
//  APIService.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 31/03/21.
//

import Foundation
import Moya
import FeedKit

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}

class APIService {

    static let shared = APIService()

    func fetchPodcast(text: String, completion: @escaping (Result<[Podcast], Error>) -> Void) {
        let provider = MoyaProvider<ItunesService>()

        provider.request(.search(name: text)) { result in
            switch result {
            case .success(let response):
                do {
                    let searchResult = try JSONDecoder().decode(SearchResults.self, from: response.data)
                    completion(.success(searchResult.results))
                } catch let decodeError {
                    completion(.failure(decodeError))
                }
            case .failure(let apiError):
                completion(.failure(apiError))
            }
        }
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

}
