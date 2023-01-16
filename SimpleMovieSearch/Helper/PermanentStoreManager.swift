//
//  PermanentStoreManager.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/24.
//

import UIKit
import Foundation

enum SaveKey: String {
    case favoriteMovies
}

class PermanentStoreManager {
    static let userDefaults = UserDefaults.standard
    
    static func saveToUserDefaults<T: Encodable>(data: T, saveKey: SaveKey) {
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: saveKey.rawValue)
        }
    }
    
    static func dataFromUserDefaults<T: Decodable>(type: T.Type, saveKey: SaveKey) -> T? {
        guard let savedData = userDefaults.object(forKey: saveKey.rawValue) as? Data,
              let decoded = try? JSONDecoder().decode(type, from: savedData)
        else {
            return nil
        }
        return decoded
    }
}
