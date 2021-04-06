//
//  SearchResultModel.swift
//  Podcast iOS
//
//  Created by Arthur Jatoba on 06/04/21.
//

import Foundation

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
