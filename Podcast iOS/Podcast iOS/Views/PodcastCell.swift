//
//  PodcastCell.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 31/03/21.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {

    static let cellId = "PodcastCell"

    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!

    var podcast: Podcast? {
        didSet {
            trackNameLabel.text = podcast?.trackName
            artistNameLabel.text = podcast?.artistName
            episodeCountLabel.text = "\(podcast?.trackCount ?? 0) Episodes"
            let url = URL(string: podcast?.artworkUrl100 ?? "")
            podcastImageView.sd_setImage(with: url, completed: nil)

        }
    }
}
