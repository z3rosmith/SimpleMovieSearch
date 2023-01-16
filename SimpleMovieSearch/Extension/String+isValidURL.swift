//
//  String+isValidURL.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/25.
//

import Foundation
import UIKit

extension String {
    var isValidURL: Bool {
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}
