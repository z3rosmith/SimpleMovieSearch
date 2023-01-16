//
//  MainSearchController.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/19.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MainSearchController: UIViewController {
    private var searchController: UISearchController?
    var moviesCollectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var emptyView: EmptyView = .init(title: "검색 결과가 없습니다.")
    
    private var disposeBag: DisposeBag = .init()
    private let viewModel: MainSearchViewModel = .init(networkService: NetworkService())
    
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

extension MainSearchController: MoviesCollectionViewProvider, FavoriteMovieUpdatableProvider {
    var movieUpdateReceiver: FavoriteMovieUpdatable {
        viewModel
    }
    
    private func bind() {
        // MARK: Input To ViewModel
        
        searchController?.searchBar.rx.searchButtonClicked
            .bind(with: self, onNext: { owner, _ in
                let searchText = owner.searchController?.searchBar.text
                owner.viewModel.input.searchMovie.onNext(searchText)
            })
            .disposed(by: disposeBag)
        
        searchController?.searchBar.rx.cancelButtonClicked
            .bind(with: self, onNext: { owner, _ in
                owner.searchController?.searchBar.text = nil
                owner.viewModel.input.clearMovieInfo.onNext(())
            })
            .disposed(by: disposeBag)
        
        let searchTextIsNil = searchController?.searchBar.rx.text.filter { $0 == "" }
        searchTextIsNil?
            .bind(with: self, onNext: { owner, _ in
                owner.viewModel.input.clearMovieInfo.onNext(())
            })
            .disposed(by: disposeBag)
        
        moviesCollectionView.rx.didScroll
            .withUnretained(self)
            .flatMap { owner, _ in
                let offSetY = owner.moviesCollectionView.contentOffset.y
                let contentHeight = owner.moviesCollectionView.contentSize.height
                let collectionViewHeight = owner.moviesCollectionView.bounds.height
                
                if offSetY > (contentHeight - collectionViewHeight - 100) {
                    return Observable.just(true)
                } else {
                    return Observable.just(false)
                }
            }
            .distinctUntilChanged()
            .filter { $0 == true }
            .subscribe(with: self, onNext: { owner, _ in
                let searchText = owner.searchController?.searchBar.text
                owner.viewModel.input.searchMoreMovie.onNext(searchText)
            })
            .disposed(by: disposeBag)
        
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
                let searchText = owner.searchController?.searchBar.text
                
                if movieCount == 0, searchText != "" {
                    owner.emptyView.isHidden = false
                } else {
                    owner.emptyView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorMessage
            .asDriver(onErrorJustReturn: "unknown")
            .drive(with: self, onNext: { owner, errorMessage in
                let errorDescription = OMDBError.getErrorDescription(from: errorMessage)
                if let errorDescription {
                    owner.presentAlert(message: errorDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchBar.placeholder = "영화를 검색하세요"
        searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "영화 검색"
    }
}
