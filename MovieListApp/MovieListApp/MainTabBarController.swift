//
//  MainTabBarController.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 30.01.2024.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTabs()
        self.configureTabBar()
    }
    
    private func configureTabBar() {
        self.selectedIndex = 2
        self.tabBar.tintColor = .red
        self.tabBar.unselectedItemTintColor = .darkGray
        self.tabBar.isTranslucent = false
        self.delegate = self
    }
    
    private func setUpTabs() {
        let home = self.createNav(with: "Movies list", and: UIImage(systemName: "list.and.film"), vc: MoviesListViewController())
        let favourites = self.createNav(with: "Favorites", and: UIImage(systemName: "heart"), vc: FavouritesViewController())
        
        self.setViewControllers([home, favourites], animated: true)
    }
    
    private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UIViewController {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = image
        return vc
    }

}

