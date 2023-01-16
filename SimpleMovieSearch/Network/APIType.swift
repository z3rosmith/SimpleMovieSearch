//
//  APIType.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/21.
//

import Foundation

protocol APIType {
    var baseURLString: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: String]? { get }
}
