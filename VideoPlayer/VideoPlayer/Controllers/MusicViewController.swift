//
//  MusicViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

class MusicViewController: AbstractMusicVideoViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var playerView: PlayerView!
    @IBOutlet private weak var fromBottomToTopPlayerViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playerViewHeightConstraint: NSLayoutConstraint!

    private let rewind = CMTime(seconds: 15, preferredTimescale: 1)
    private var player = AVPlayer()
    private var nowPlayingInfo = [String: Any]()

    override func viewDidLoad() {
//        UserDefaults.standard.removeObject(forKey: "MusicList")
        setSomeParameter(tableView: tableView, userDefaultsKey: "MusicList", itemExtension: ".mp3", view: EmptyMusicListView.loadFromNib())
        super.viewDidLoad()
        //setup player view
        playerView.setUpPropertyForAnimation(allHeight: playerViewHeightConstraint.constant,
                                             notVizibleHeight: playerViewHeightConstraint.constant - fromBottomToTopPlayerViewConstraint.constant)
        playerView.delegat = self
        setupRemoteCommandCenter()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.setGradientBackground()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.finishedAnimation()
    }

    //MARK: - overrided functions
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let currentItem = object as! AVPlayer
        print(currentItem.rate)
        if currentItem.rate > 0.0 {
            playerView.changePlayButtonIcon(playNow: true)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        } else {
            playerView.changePlayButtonIcon(playNow: false)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        }
        updateInformationOnLockScreen()
    }

    override func startPlay(atIndex index: Int, autoPlay autoplay: Bool = true) {
        guard   !itemsArray.isEmpty,
                index >= 0,
                index < itemsArray.count
        else {return}

        indexOfCurrentItem = index
        unNewTrackAtIndex(index)
        let url = FileManager.default.getTempDirectory().appendingPathComponent(itemsArray[index].fileName, isDirectory: false)

        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlay), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        player = AVPlayer.init(playerItem: playerItem)
        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)

        if autoplay {
            player.play()
        }
        displayMusicInfo(fileUrl: url)
    }

    //MARK: setup remote command for display buttons on lock screen and in menu
    fileprivate func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] (object) -> MPRemoteCommandHandlerStatus in
            guard let self = self else {return .commandFailed}
            let event = object as! MPChangePlaybackPositionCommandEvent
            self.rewindPlayerItemTo(CMTime.init(seconds: event.positionTime, preferredTimescale: 1))
            return .success
        }
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else {return .commandFailed}
            self.player.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else {return .commandFailed}
            self.player.pause()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let self = self else {return .commandFailed}
            if (self.indexOfCurrentItem ?? -1) + 1 <= self.itemsArray.count - 1 {
                self.startPlay(atIndex: self.indexOfCurrentItem!+1)
                return .success
            } else {
                return .noSuchContent
            }
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let self = self else {return .commandFailed}
            if (self.indexOfCurrentItem ?? +1) - 1 >= 0 {
                self.startPlay(atIndex: self.indexOfCurrentItem!-1)
                return .success
            } else {
                return .noSuchContent
            }
        }
    }

    //MARK: setup information about track on lock screen and in menu
    fileprivate func displayMusicInfo(fileUrl: URL) {
        nowPlayingInfo = [String: Any]()
        var imageForPlayerView: UIImage! = UIImage.init(named: "mp3")
        let asset = AVAsset(url: fileUrl) as AVAsset

        for metaDataItems in asset.commonMetadata {
            switch metaDataItems.commonKey!.rawValue {
            case "artist":
                guard let artist = metaDataItems.value as? String else {break}
                nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            case "albumName":
                guard let album = metaDataItems.value as? String else {break}
                nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
            case "artwork":
                guard   let imageData = metaDataItems.value as? Data,
                        let image = UIImage(data: imageData) else {break}
                imageForPlayerView = image
            default:
                continue
            }
        }

        nowPlayingInfo[MPMediaItemPropertyTitle] = itemsArray[indexOfCurrentItem!].fileName

        let artwork: MPMediaItemArtwork!
        if #available(iOS 10.0, *) {
            artwork = MPMediaItemArtwork.init(boundsSize: imageForPlayerView.size, requestHandler: { (size) -> UIImage in
                return imageForPlayerView
            })
        } else {
            artwork = MPMediaItemArtwork.init(image: imageForPlayerView)
        }

        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem!.asset.duration.seconds

        playerView.updateViewWith(text: nowPlayingInfo[MPMediaItemPropertyTitle] as! String, image: imageForPlayerView)

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    fileprivate func updateInformationOnLockScreen() {
        print(player.currentTime().stringSeconds)
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds as CFNumber
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    @objc fileprivate func playerDidFinishPlay() {
        guard   let index = indexOfCurrentItem,
                index + 1 <= itemsArray.count - 1
        else {return}

        startPlay(atIndex: index+1)
    }

    fileprivate func rewindPlayerItemTo(_ rewindTo: CMTime) {
        guard player.currentItem != nil else {return}
        player.seek(to: rewindTo) { [weak self] (flag) in
            guard let self = self, flag else {return}
            self.updateInformationOnLockScreen()
        }
    }
}

extension MusicViewController: PlayerViewDelegate {
    func updateTimeLabel() -> (Double, Double)? {
        if player.currentItem != nil {
            return (player.currentTime().seconds, player.currentItem!.asset.duration.seconds)
        } else {
            return nil
        }
    }

    func previousTrackDidTap(sender: PlayerView) {
        guard let index = indexOfCurrentItem, index-1 <= self.itemsArray.count - 1 else {
            self.startPlay(atIndex: 0)
            return
        }
        self.startPlay(atIndex: index-1)
    }

    func forwardRewindDidTap(sender: PlayerView) {
        let rewindTo = player.currentTime() + rewind
        rewindPlayerItemTo(rewindTo)
    }

    func playAndPauseDidTap(sender: PlayerView) {
        guard player.currentItem != nil else {
            startPlay(atIndex: 0)
            return
        }
        if player.rate > 0.0 {
            player.pause()
        } else {
            player.play()
        }
    }

    func forcePlayOrPause(sender: PlayerView, shoudPlay: Bool, seekTo: Float?) {
        guard player.currentItem != nil else {return}

        if shoudPlay {
            rewindPlayerItemTo(CMTime.init(seconds: Double(seekTo!), preferredTimescale: 1))
            player.play()
        } else {
            player.pause()
        }
    }

    func backRewindDidTap(sender: PlayerView) {
        let rewindTo = player.currentTime() - rewind
        rewindPlayerItemTo(rewindTo)
    }

    func nextTrackDidTap(sender: PlayerView) {
        guard let index = indexOfCurrentItem, index+1 <= self.itemsArray.count - 1 else {
            self.startPlay(atIndex: 0)
            return
        }
        self.startPlay(atIndex: index+1)
    }
}
