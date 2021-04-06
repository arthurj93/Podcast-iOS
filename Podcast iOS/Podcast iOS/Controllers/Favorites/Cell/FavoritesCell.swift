//
//  FavoritesCell.swift
//  Podcast iOS
//
//  Created by Arthur Jatoba on 05/04/21.
//

import UIKit

class FavoritesCell: UICollectionViewCell {
    static let cellId = "FavoritesCell"

    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    var podcast: Podcast? {
        didSet {
            nameLabel.text = podcast?.trackName
            artistNameLabel.text = podcast?.artistName
            guard let url = URL(string: podcast?.artworkUrl100 ?? "") else { return }
            podcastImageView.sd_setImage(with: url)
        }
    }
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
