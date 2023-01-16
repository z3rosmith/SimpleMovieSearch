//
//  MoviesCollectionViewProvider.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/19.
//

import UIKit

protocol MoviesCollectionViewProvider where Self: UIViewController {
    var moviesCollectionView: UICollectionView { get set }
    var emptyView: EmptyView { get }
    
    func configureCollectionViewFlowLayout(numberOfItemsInRow: Int)
    func configureCollectionView()
    func configureEmptyView()
}

extension MoviesCollectionViewProvider {
    func configureCollectionViewFlowLayout(numberOfItemsInRow: Int = 2) {
        guard let flowLayout = moviesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let number = CGFloat(numberOfItemsInRow)
        let horizontalMargin: CGFloat = 15
        let width = UIScreen.main.bounds.width
        let contentWidth = width - horizontalMargin * (number + 1)
        let itemWidth = contentWidth / number
        let itemHeight = itemWidth * 1.7 // 영화 포스터 비율은 보통 1:1.3이므로 0.4의 비율을 더 주었음(label이 밑에 더 있으므로)
        
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        flowLayout.minimumLineSpacing = horizontalMargin
        flowLayout.minimumInteritemSpacing = horizontalMargin
        flowLayout.sectionInset = UIEdgeInsets(top: horizontalMargin, left: horizontalMargin, bottom: horizontalMargin, right: horizontalMargin)
    }
    
    func configureCollectionView() {
        moviesCollectionView.backgroundColor = .white
        moviesCollectionView.keyboardDismissMode = .onDrag
        moviesCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        
        view.addSubview(moviesCollectionView)
        
        moviesCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureEmptyView() {
        emptyView.isHidden = true
        moviesCollectionView.backgroundView = emptyView
    }
}
