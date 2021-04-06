//
//  DownloadsController.swift
//  Podcast iOS
//
//  Created by Arthur Jatoba on 06/04/21.
//

import UIKit
class DownloadsController: UITableViewController {
    
    var episodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupObservers()
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    @objc func handleDownloadComplete(notification: Notification) {
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuble else { return }
        guard let index = self.episodes.firstIndex(where: {$0.title == episodeDownloadComplete.episodeTitle }) else { return }
        self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
    }
    
    @objc func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }
        guard let index = self.episodes.firstIndex(where: {$0.title == title }) else { return }
        DispatchQueue.main.async {
            guard let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
            cell.progressLabel.isHidden = false
            cell.progressLabel.text = "\(Int(progress * 100))%"
            
            if progress == 1 {
                cell.progressLabel.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.tableFooterView = .init()
        tableView.register(UINib(nibName: EpisodeCell.cellId, bundle: nil), forCellReuseIdentifier: EpisodeCell.cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellId, for: indexPath) as? EpisodeCell else { return .init() }
        cell.episode = episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = deleteHandlerAction(indexPath: indexPath)
            let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
            return swipeActions
    }
    
    private func deleteHandlerAction(indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (_, _, completion) in
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.deleteEpisode(episode: episode)
            self.episodes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        return deleteAction
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
        } else {
            let alertController = UIAlertController(title: "File URL not found", message: "Cannot Find local file, play using url instead", preferredStyle: .actionSheet)
            alertController.addAction(.init(title: "Yes", style: .default, handler: { _ in
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
            }))
            alertController.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true)
        }
        
    }
}
