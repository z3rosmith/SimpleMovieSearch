//
//  MainSearchViewModel.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/20.
//

import Foundation
import RxSwift
import RxRelay

final class MainSearchViewModel: ViewModelType {
    typealias Item = Movie
    
    struct Input {
        let searchMovie: AnyObserver<String?>
        let searchMoreMovie: AnyObserver<String?>
        let didSelectCell: AnyObserver<IndexPath>
        let clearMovieInfo: AnyObserver<Void>
    }
    
    struct Output {
        let movieList: Observable<[Item]>
        let errorMessage: Observable<String>
    }
    
    var disposeBag: DisposeBag = .init()
    let input: Input
    let output: Output
    
    private var page: Int = 1
    private var movieStore: [Item] = []
    private var hasMoreMovie: Bool = true
    
    private let movieList: PublishRelay<[Item]> = .init()
    private let errorMessage: PublishRelay<String> = .init()
    private let networkService: NetworkServiceProvider
    
    init(networkService: NetworkServiceProvider) {
        let searchMovie = PublishSubject<String?>()
        let searchMoreMovie = PublishSubject<String?>()
        let didSelectCell = PublishSubject<IndexPath>()
        let clearMovieInfo = PublishSubject<Void>()
        
        self.networkService = networkService
        
        self.input = Input(
            searchMovie: searchMovie.asObserver(),
            searchMoreMovie: searchMoreMovie.asObserver(),
            didSelectCell: didSelectCell.asObserver(),
            clearMovieInfo: clearMovieInfo.asObserver()
        )
        
        self.output = Output(
            movieList: movieList.asObservable(),
            errorMessage: errorMessage.asObservable()
        )
        
        searchMovie
            .subscribe(with: self, onNext: { owner, movieTitle in
                owner.fetchMovie(movieTitle: movieTitle, isInitialFetch: true)
            })
            .disposed(by: disposeBag)
        
        searchMoreMovie
            .subscribe(with: self, onNext: { owner, movieTitle in
                owner.fetchMovie(movieTitle: movieTitle, isInitialFetch: false)
            })
            .disposed(by: disposeBag)
        
        didSelectCell
            .subscribe(with: self, onNext: { owner, indexPath in
                owner.didSelectCell(at: indexPath)
            })
            .disposed(by: disposeBag)
        
        clearMovieInfo
            .subscribe(with: self, onNext: { owner, _ in
                owner.clearMovieInfo()
                owner.movieList.accept([])
            })
            .disposed(by: disposeBag)
    }
}

extension MainSearchViewModel: FavoriteMovieUpdatable {
    func getMovie(at indexPath: IndexPath) -> Movie {
        movieStore[indexPath.item]
    }
    
    func updateFavoriteMovie(movie: Movie, action: FavoriteMovieUpdateAction) {
        guard let index = movieStore.firstIndex(where: { $0 == movie }) else {
            return
        }
        
        switch action {
        case .add:
            movieStore[index].isFavorite = true
        case .delete:
            movieStore[index].isFavorite = false
        }
        
        movieList.accept(movieStore)
    }
    
    private func clearMovieInfo() {
        movieStore.removeAll()
        page = 1
        hasMoreMovie = true
    }
    
    private func fetchMovie(movieTitle: String?, isInitialFetch: Bool) {
        if isInitialFetch {
            clearMovieInfo()
        }
        
        guard hasMoreMovie, let movieTitle, !movieTitle.isEmpty else { return }
        
        defer {
            page += 1
        }
        
        let api = MovieAPI.search(movieTitle: movieTitle, page: page)
        networkService
            .request(api: api, type: MovieRequestDTO.self)
            .withUnretained(self)
            .subscribe(onNext: { owner, data in
                if data.response == "True" {
                    let movieInfoList = data.movieInfoList
                    let favoriteMovieList = PermanentStoreManager.dataFromUserDefaults(
                        type: [Item].self,
                        saveKey: .favoriteMovies
                    )
                    let movieList = movieInfoList.map {
                        var movie = Movie(from: $0)
                        if favoriteMovieList?.contains(where: { $0 == movie }) == true {
                            movie.isFavorite = true
                        }
                        return movie
                    }
                    owner.movieStore.append(contentsOf: movieList)
                    owner.movieList.accept(owner.movieStore)
                    
                    guard let totalResults = data.totalResultsInt else { return }
                    
                    owner.hasMoreMovie = owner.movieStore.count < totalResults
                } else {
                    guard let error = data.error else { return }
                    
                    ErrorMessagePrinter.print(errorDescription: error)
                    
                    if isInitialFetch {
                        owner.movieList.accept([])
                        owner.errorMessage.accept(error)
                    }
                }
            }, onError: { error in
                ErrorMessagePrinter.print(error: error)
            })
            .disposed(by: disposeBag)
    }
}
