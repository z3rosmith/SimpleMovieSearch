//
//  ImageLoader.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/22.
//

import UIKit
import RxSwift

enum ImageLoaderError: Error {
    case noData
    case noLoadingResponses
    case unknown(error: Error?)
}

final class ImageLoader {
    typealias ResponseClosureType = (Result<UIImage, ImageLoaderError>) -> Void
    
    static let shared = ImageLoader()
    
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingTasks = [UICollectionViewCell: URLSessionDataTask]()
    
    private init() {
        // 캐시의 제한 용량을 50MB로 초기화
        configureCachePolicy(with: 52428800)
    }
    
    private func configureCachePolicy(with maximumBytes: Int) {
        cachedImages.totalCostLimit = maximumBytes
    }
    
    func image(url: NSURL) -> UIImage? {
        cachedImages.object(forKey: url)
    }
    
    func load(url: NSURL, cell: UICollectionViewCell, completion: @escaping ResponseClosureType) {
        if let cachedImage = image(url: url) {
            completion(.success(cachedImage))
            return
        }
        
        // 한 cell에 대해서 이미 task가 발생해있으면 취소함.
        if let loadingTask = loadingTasks[cell] {
            loadingTask.cancel()
            loadingTasks[cell] = nil
        }
        
        let task = URLSession.shared.dataTask(with: url as URL) { [weak self] data, response, error in
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  error == nil
            else {
                completion(.failure(ImageLoaderError.unknown(error: error)))
                return
            }
            
            guard let data,
                  let image = UIImage(data: data)
            else {
                completion(.failure(ImageLoaderError.noData))
                return
            }
            
            self?.cachedImages.setObject(image, forKey: url, cost: data.count)
            
            completion(.success(image))
        }
        
        loadingTasks[cell] = task
        task.resume()
    }
    
    func load(url: NSURL, cell: UICollectionViewCell) -> Observable<UIImage> {
        return Observable.create { [weak self] emitter in
            self?.load(url: url, cell: cell) { result in
                switch result {
                case .success(let image):
                    emitter.onNext(image)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
