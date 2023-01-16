//
//  FavoriteMoviesViewModel.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/24.
//

import Foundation
import RxSwift
import RxRelay

final class FavoriteMoviesViewModel: ViewModelType {
    typealias Item = Movie
    
    struct Input {
        let didSelectCell: AnyObserver<IndexPath>
    }
    
    struct Output {
        let movieList: Observable<[Item]>
    }
    
    var disposeBag: DisposeBag = .init()
    let input: Input
    let output: Output
    
    private var movieStore: [Item] = []
    private let movieList: BehaviorRelay<[Item]> = .init(value: [])
    
    init() {
        let didSelectCell = PublishSubject<IndexPath>()
        
        self.input = Input(
            didSelectCell: didSelectCell.asObserver()
        )
        
        self.output = Output(
            movieList: movieList.asObservable()
        )
        
        didSelectCell
            .subscribe(with: self, onNext: { owner, indexPath in
                owner.didSelectCell(at: indexPath)
            })
            .disposed(by: disposeBag)
        
        setMovieStore()
    }
}

extension FavoriteMoviesViewModel: FavoriteMovieUpdatable {
    func getMovie(at indexPath: IndexPath) -> Movie {
        movieStore[indexPath.item]
    }
    
    func updateFavoriteMovie(movie: Movie, action: FavoriteMovieUpdateAction) {
        var movie = movie
        
        switch action {
        case .add:
            movie.isFavorite = true
            movieStore.append(movie)
        case .delete:
            guard let index = movieStore.firstIndex(where: { $0 == movie }) else {
                return
            }
            movieStore.remove(at: index)
        }
        
        saveToUserDefaults()
        movieList.accept(movieStore)
    }
    
    private func saveToUserDefaults() {
        PermanentStoreManager.saveToUserDefaults(
            data: movieStore,
            saveKey: .favoriteMovies
        )
    }
    
    private func setMovieStore() {
        guard let movies = PermanentStoreManager.dataFromUserDefaults(
            type: [Item].self,
            saveKey: .favoriteMovies
        ) else {
            return
        }
        
        movieStore = movies
        movieList.accept(movies)
    }
}
