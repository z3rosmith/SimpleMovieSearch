//
//  NetworkService.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/19.
//

import Foundation
import RxSwift
import RxCocoa

enum NetworkServiceError: Error, CustomDebugStringConvertible {
    case invalidURL
    case invalidAPIInfo
    
    var debugDescription: String {
        switch self {
        case .invalidURL:
            return "Cannot convert urlString to URL"
        case .invalidAPIInfo:
            return "Cannot create request from API"
        }
    }
}

final class NetworkService: NetworkServiceProvider {
    private let session: URLSession = URLSession.shared

    func request(api: APIType) -> Observable<Data> {
        guard let request = createURLRequest(api: api) else {
            return Observable.error(NetworkServiceError.invalidAPIInfo)
        }
        
        return session.rx.data(request: request)
    }
    
    func request<T: Decodable>(api: APIType, type: T.Type) -> Observable<T> {
        return self.request(api: api).map {
            try JSONDecoder().decode(type, from: $0)
        }
    }
    
    private func createURLRequest(
        api: APIType
    ) -> URLRequest? {
        guard var components = URLComponents(string: api.baseURLString) else { return nil }
        
        components.queryItems = api.parameters?.map{ key, value in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = api.method.rawValue
        api.headers?.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        return request
    }
}
