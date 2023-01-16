//
//  FavoriteMoviesController.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/19.
//

import UIKit
import RxSwift
import RxCocoa

final class FavoriteMoviesController: UIViewController {
    var moviesCollectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var emptyView: EmptyView = .init(title: "즐겨찾기 한 영화가 없습니다.")
    
    private var disposeBag: DisposeBag = .init()
    private let viewModel: FavoriteMoviesViewModel = .init()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        configureCollectionView()
        configureCollectionViewFlowLayout()
        configureEmptyView()
        bind()
    }
}

extension FavoriteMoviesController: MoviesCollectionViewProvider, FavoriteMovieUpdatableProvider {
    var movieUpdateReceiver: FavoriteMovieUpdatable {
        viewModel
    }
    
    private func bind() {
        // MARK: Input To ViewModel
        
        moviesCollectionView.rx.itemSelected
            .bind(with: self, onNext: { owner, indexPath in
                let movie = owner.viewModel.getMovie(at: indexPath)
                let movieTitle = movie.title
                let isFavoriteMovie = movie.isFavorite
                owner.presentAlertAboutEditingFavoriteMovie(
                    movieTitle: movieTitle,
                    isFavoriteMovie: isFavoriteMovie,
                    doWhenOKTapped: {
                    owner.viewModel.input.didSelectCell.onNext(indexPath)
                })
            })
            .disposed(by: disposeBag)
        
        // MARK: Output From ViewModel
        
        let movieList = viewModel.output.movieList
        
        movieList
            .observe(on: MainScheduler.instance)
            .bind(to: moviesCollectionView.rx.items(
                cellIdentifier: MovieCollectionViewCell.identifier,
                cellType: MovieCollectionViewCell.self
            )) { index, movie, cell in
                cell.update(from: movie)
            }
            .disposed(by: disposeBag)
        
        movieList
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { owner, movieCount in
                if movieCount == 0 {
                    owner.emptyView.isHidden = false
                } else {
                    owner.emptyView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureController() {
        navigationItem.title = "내 즐겨찾기"
    }
}
