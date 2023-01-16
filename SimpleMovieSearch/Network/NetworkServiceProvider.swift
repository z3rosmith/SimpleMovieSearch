//
//  NetworkServiceProvider.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/20.
//

import Foundation
import RxSwift

protocol NetworkServiceProvider {
    func request(api: APIType) -> Observable<Data>
    func request<T: Decodable>(api: APIType, type: T.Type) -> Observable<T>
}
