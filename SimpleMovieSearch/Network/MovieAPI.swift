//
//  MovieAPI.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/21.
//

import Foundation

enum MovieAPI {
    case search(movieTitle: String, page: Int)
}

extension MovieAPI: APIType {
    var baseURLString: String {
        "http://www.omdbapi.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .search:
            return .get
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .search:
            return nil
        }
    }
    
    var parameters: [String : String]? {
        var params: [String: String] = ["apikey": "1e12510e"]
        
        switch self {
        case .search(let movieTitle, let page):
            params.updateValue(movieTitle, forKey: "s")
            params.updateValue(String(page), forKey: "page")
            return params
        }
    }
}
