//
//  PodcastsSearchController.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 30/03/21.
//

import UIKit
import Moya

class PodcastsSearchController: UITableViewController {

    var podcasts: [Podcast] = []
    var timer: Timer?

    let searchController = UISearchController(searchResultsController: nil)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        searchBar(searchController.searchBar, textDidChange: "Voong") //deletar dps
    }

    //MARK:- Setup Work
    private func setupSearchBar() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }

    private func setupTableView() {
        tableView.tableFooterView = .init()
        tableView.register(UINib(nibName: PodcastCell.cellId, bundle: nil), forCellReuseIdentifier: PodcastCell.cellId)
    }
    
}

extension PodcastsSearchController {
    //MARK:- UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.cellId, for: indexPath) as? PodcastCell else { return .init() }
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }

}

extension PodcastsSearchController {
    //MARK:- UITableViewDelegate

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a search term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podcasts.count > 0 ? 0 : 250

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        episodesController.modalPresentationStyle = .fullScreen
        let podcast = podcasts[indexPath.row]
        episodesController.podcast = podcast
        navigationController?.pushViewController(episodesController, animated: true)
    }

}

extension PodcastsSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            APIService.shared.fetchPodcast(text: searchText) { result in
                switch result {
                case .success(let podcasts):
                    self.podcasts = podcasts
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }

            }
        })
    }
}
