//
//  MovieInfo.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/19.
//

import Foundation

struct MovieInfo: Codable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
}
