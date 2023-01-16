//
//  MovieRequestDTO.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/19.
//

import Foundation

struct MovieRequestDTO: Decodable {
    let search: [MovieInfo]?
    let totalResults: String?
    let error: String?
    let response: String
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case error = "Error"
        case response = "Response"
    }
}

extension MovieRequestDTO {
    var movieInfoList: [MovieInfo] {
        return search == nil ? [] : search!
    }
    
    var totalResultsInt: Int? {
        if let totalResults, let integerValue = Int(totalResults) {
            return integerValue
        }
        return nil
    }
}
