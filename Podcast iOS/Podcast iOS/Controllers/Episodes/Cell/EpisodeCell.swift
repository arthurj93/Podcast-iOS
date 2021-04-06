//
//  EpisodeCell.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 31/03/21.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {
    static let cellId = "EpisodeCell"

    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    var episode: Episode? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode?.pubDate ?? Date())
            descriptionLabel.text = episode?.description
            titleLabel.text = episode?.title
            let url = URL(string: episode?.imageUrl ?? "")
            episodeImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
}
