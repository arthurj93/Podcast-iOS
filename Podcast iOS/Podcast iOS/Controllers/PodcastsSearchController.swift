//
//  PodcastsSearchController.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 30/03/21.
//

import UIKit
import Moya

class PodcastsSearchController: UITableViewController {

    var podcasts: [Podcast] = [.init(trackName: "Lets Build That App", artistName: "Brian Voong"),
                               .init(trackName: "Some Podcast", artistName: "Some Author")]

    let searchController = UISearchController(searchResultsController: nil)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
    }

    //MARK:- Setup Work
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }

    private func setupTableView() {
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(UINib(nibName: PodcastCell.cellId, bundle: nil), forCellReuseIdentifier: PodcastCell.cellId)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //MARK:- UITableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return podcasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.cellId, for: indexPath) as? PodcastCell else { return .init() }
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
//        cell.textLabel?.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
//        cell.textLabel?.numberOfLines = 0
//        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
}

extension PodcastsSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        APIService.shared.fetchPodcast(text: searchText) { result in
            switch result {
            case .success(let podcasts):
                self.podcasts = podcasts
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }

        }
    }
}

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
