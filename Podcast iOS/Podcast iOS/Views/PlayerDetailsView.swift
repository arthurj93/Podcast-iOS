//
//  PlayerDetailsView.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 31/03/21.
//

import UIKit
import AVKit

protocol PlayerDetailsViewDelegate: class {

}

class PlayerDetailsView: UIView {

    static let xibName = "PlayerDetailsView"

    weak var delegate: PlayerDetailsViewDelegate?
    let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)

    //MARK:- PlayerView Outlets

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.transform = shrunkenTransform
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var volumeStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @IBOutlet weak var maximizePlayerView: UIView!

    //MARK:- MiniView Outlets
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @IBOutlet weak var miniFastForwardButton: UIButton!

    let player: AVPlayer = {
        let avPlayer: AVPlayer = .init()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()

    var episode: Episode? {
        didSet {
            miniTitleLabel.text = episode?.title
            titleLabel.text = episode?.title
            authorLabel.text = episode?.author
            guard let url = URL(string: episode?.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
            miniEpisodeImageView.sd_setImage(with: url, completed: nil)
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)

            playEpisode()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        observePlayerCurrentTime()
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeEpisodeImageView()
        }
    }

    //MARK: - HandleView

    @objc func handleTapMaximize() {
        let mainTabBarController = UIApplication.shared.windows.filter { $0.isKeyWindow}.first?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails()
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handlePanChanged(gesture: gesture)

        } else if gesture.state == .ended {
            handlePanEnded(gesture: gesture)
        }
    }

    func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.maximizePlayerView.alpha = -translation.y / 200
        self.volumeStackView.alpha = 0
    }

    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                let mainTabBarController = UIApplication.shared.windows.filter { $0.isKeyWindow}.first?.rootViewController as? MainTabBarController
                mainTabBarController?.maximizePlayerDetails()
                self.volumeStackView.alpha = 1
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizePlayerView.alpha = 0
            }
        }

    }

    @objc private func handlePlayPause() {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
        }
    }

    //MARK: - IBActions

    @IBAction func handleDismiss(_ sender: Any) {
        let mainTabBarController = UIApplication.shared.windows.filter { $0.isKeyWindow}.first?.rootViewController as? MainTabBarController
        mainTabBarController?.minimizePlayerDetails()
    }

    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTime(seconds: seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }

    @IBAction func handleRewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }

    @IBAction func handleFastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }

    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value    
    }

}

extension PlayerDetailsView {
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed(PlayerDetailsView.xibName, owner: self, options: nil)?.first as! PlayerDetailsView
    }
}

extension PlayerDetailsView {

    //MARK:- PlayerAVKit functions

    private func playEpisode() {
        guard let url = URL(string: episode?.streamUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }

    fileprivate func observePlayerCurrentTime() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in

            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            self?.updateCurrentTimeSlider()
        }
    }

    private func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.episodeImageView.transform = .identity
        }
    }

    private func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.episodeImageView.transform = self.shrunkenTransform
        }
    }

    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }

    private func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTime(seconds: Double(delta), preferredTimescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
}
