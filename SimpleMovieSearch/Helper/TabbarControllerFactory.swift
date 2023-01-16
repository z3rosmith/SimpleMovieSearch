//
//  TabbarControllerFactory.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/19.
//

import UIKit

final class TabbarControllerFactory {
    private init() { }
    
    static func make() -> UITabBarController {
        let tabbarController = UITabBarController()
        let search = MainSearchController()
        let favorite = FavoriteMoviesController()
        let navController1 = UINavigationController(rootViewController: search)
        navController1.tabBarItem = UITabBarItem(title: "검색", image: UIImage(named: "magnifyingglass"), selectedImage: nil)
        let navController2 = UINavigationController(rootViewController: favorite)
        navController2.tabBarItem = UITabBarItem(title: "즐겨찾기", image: UIImage(named: "star"), selectedImage: nil)
        tabbarController.viewControllers = [navController1, navController2]
        
        // 탭바 컨트롤러를 사용 할 때, 선택되어 있지 않은 탭은 viewDidLoad가 불리지 않는다.
        // 이를 해결하기 위해 다음의 코드를 작성하였음.
        tabbarController.viewControllers?.forEach {
            if let navController = $0 as? UINavigationController {
                let _ = navController.topViewController?.view
            } else {
                let _ = $0.view
            }
        }
        return tabbarController
    }
}
