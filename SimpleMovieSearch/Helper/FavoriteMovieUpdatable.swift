//
//  FavoriteMovieUpdatable.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/23.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

enum FavoriteMovieUpdateAction {
    case add
    case delete
}

protocol FavoriteMovieUpdatable {
    func getMovie(at indexPath: IndexPath) -> Movie
    func updateFavoriteMovie(movie: Movie, action: FavoriteMovieUpdateAction)
    func didSelectCell(at indexPath: IndexPath)
}

protocol FavoriteMovieUpdatableProvider {
    var movieUpdateReceiver: FavoriteMovieUpdatable { get }
}

extension FavoriteMovieUpdatable {
    func didSelectCell(at indexPath: IndexPath) {
        let movie = getMovie(at: indexPath)
        let action: FavoriteMovieUpdateAction = movie.isFavorite ? .delete : .add
        
        let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController
        
        tabBarController?.viewControllers?.forEach {
            if let navController = $0 as? UINavigationController {
                navController.viewControllers
                    .compactMap { $0 as? FavoriteMovieUpdatableProvider }
                    .forEach {
                        $0.movieUpdateReceiver.updateFavoriteMovie(movie: movie, action: action)
                    }
            } else {
                var vc: UIViewController? = $0
                repeat {
                    (vc as? FavoriteMovieUpdatableProvider)?
                        .movieUpdateReceiver
                        .updateFavoriteMovie(movie: movie, action: action)
                    vc = vc?.presentedViewController
                } while vc != nil
            }
        }
    }
}
