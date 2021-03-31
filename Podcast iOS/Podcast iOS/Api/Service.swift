//
//  Service.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 30/03/21.
//

import Foundation
import Moya

enum ItunesService {
    case search(name: String)
    case test
}

extension ItunesService: TargetType {
    var baseURL: URL { return URL(string: "https://itunes.apple.com")! }

    var path: String {
        switch self {
        case .search:
            return "/search"
        default:
            return ""
        }
    }

    var method: Moya.Method {
        switch self {
        case .search:
            return .get
        default:
            return .post
        }
    }

    var sampleData: Data {
        return .init()
    }

    var task: Task {
        switch self {
        case .search(let name):
            let parameters = ["term": name, "media": "podcast"]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }

}
