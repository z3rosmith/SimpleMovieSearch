//
//  Movie.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/22.
//

import Foundation

struct Movie: Codable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String
    var isFavorite: Bool = false
}

extension Movie: Equatable {
    init(from movieInfo: MovieInfo) {
        self.init(
            title: movieInfo.title,
            year: movieInfo.year,
            imdbID: movieInfo.imdbID,
            type: movieInfo.type,
            poster: movieInfo.poster
        )
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.imdbID == rhs.imdbID
    }
}
