//
//  ViewModelType.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/20.
//

import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    var input: Input { get }
    var output: Output { get }
}
