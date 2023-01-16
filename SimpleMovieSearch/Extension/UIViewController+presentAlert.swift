//
//  UIViewController+presentAlert.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/24.
//

import UIKit

extension UIViewController {
    func presentAlertAboutEditingFavoriteMovie(
        movieTitle: String? = nil,
        isFavoriteMovie: Bool,
        doWhenOKTapped: @escaping (() -> Void)
    ) {
        let actionText = isFavoriteMovie ? "즐겨찾기 제거" : "즐겨찾기"
        
        let alertController = UIAlertController(
            title: movieTitle,
            message: nil,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: actionText,
            style: .default
        ) { _ in
            doWhenOKTapped()
        }
        
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel
        )
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentAlert(
        title: String? = nil,
        message: String? = nil
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(
            title: "승인",
            style: .default
        )
        
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
