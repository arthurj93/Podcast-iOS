//
//  MainTabBarController.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 29/03/21.
//

import UIKit

class MainTabBarController: UITabBarController {

    let playerDetailsView = PlayerDetailsView.initFromNib()

    var maximizedTopAnchorConstraints: NSLayoutConstraint!
    var minimizedTopAnchorConstraints: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .purple
        setupViewControllers()
        setupPlayerDetailView()
    }

    //MARK:- Setup Functions

    func setupPlayerDetailView() {
        view.insertSubview(playerDetailsView, belowSubview: tabBar)

        maximizedTopAnchorConstraints = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraints = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        maximizedTopAnchorConstraints.isActive = true

        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func setupViewControllers() {
        viewControllers = [
            generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(with: ViewController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }

    @objc func minimizePlayerDetails() {

        maximizedTopAnchorConstraints.isActive = false
        minimizedTopAnchorConstraints.isActive = true

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.isHidden = false
            self.playerDetailsView.maximizePlayerView.alpha = 0
            self.playerDetailsView.miniPlayerView.alpha = 1
        }

    }

    func maximizePlayerDetails(episode: Episode? = nil) {
        maximizedTopAnchorConstraints.isActive = true
        minimizedTopAnchorConstraints.isActive = false
        maximizedTopAnchorConstraints.constant = 0

        if episode != nil {
            playerDetailsView.episode = episode
        }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.isHidden = true
            self.playerDetailsView.maximizePlayerView.alpha = 1
            self.playerDetailsView.miniPlayerView.alpha = 0
        }
    }

    //MARK:- Helper Functions
    private func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        rootViewController.configureNavigationBar(largeTitleColor: .black,
                                                  backgoundColor: .white,
                                                  tintColor: .black,
                                                  title: title,
                                                  preferredLargeTitle: true)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }

}
