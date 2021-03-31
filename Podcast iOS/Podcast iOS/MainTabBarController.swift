//
//  MainTabBarController.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 29/03/21.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        view.backgroundColor = .green
        tabBar.tintColor = .purple
        setupViewControllers()

        // Do any additional setup after loading the view.
    }

    //MARK:- Setup Functions

    func setupViewControllers() {
        viewControllers = [
            generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(with: ViewController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }


    //MARK:- Helper Functions
    private func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        rootViewController.configureNavigationBar(largeTitleColor: .black,
                                                  backgoundColor: .white,
                                                  tintColor: .white,
                                                  title: title,
                                                  preferredLargeTitle: true)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }

}
