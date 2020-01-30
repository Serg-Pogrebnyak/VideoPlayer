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
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var playerView: PlayerView!
    @IBOutlet fileprivate weak var fromBottomToTopPlayerViewConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var playerViewHeightConstraint: NSLayoutConstraint!

    fileprivate var player: AVAudioPlayer?

    override func viewDidLoad() {
        setSomeParameter(tableView: tableView, userDefaultsKey: "MusicList", itemExtension: ".mp3")
        super.viewDidLoad()
        //setup player view
        playerView.setUpPropertyForAnimation(allHeight: playerViewHeightConstraint.constant,
                                             notVizibleHeight: playerViewHeightConstraint.constant - fromBottomToTopPlayerViewConstraint.constant)
        playerView.delegat = self
        //UserDefaults.standard.removeObject(forKey: musicUserDefaultsKey)
        setupRemoteCommandCenter()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.setGradientBackground()
    }

    override func startPlay(atIndex index: Int, autoPlay autoplay: Bool = true) {
        indexOfCurrentItem = index
        unNewTrackAtIndex(index)
        let url = FileManager.default.getURLS().appendingPathComponent(itemsArray[index].fileName, isDirectory: false)
        do {

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }

            if autoplay {
                player.play()
            }
            player.delegate = self
            playerView.changePlayButtonIcon(playNow: player.isPlaying)
            displayMusicInfo(fileUrl: url)
        } catch let error {
            showErrorAlertWithMessage(error.localizedDescription)
        }
    }

    //MARK: setup remote command for display buttons on lock screen and in menu
    fileprivate func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            self.playerView.changePlayButtonIcon(playNow: true)
            self.player?.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            self.playerView.changePlayButtonIcon(playNow: false)
            self.player?.pause()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget {event in
            if (self.indexOfCurrentItem ?? -1) + 1 <= self.itemsArray.count - 1 {
                self.startPlay(atIndex: self.indexOfCurrentItem!+1)
                return .success
            } else {
                return .noSuchContent
            }
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget {event in
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
        var imageForPlayerView: UIImage! = UIImage.init(named: "mp3")
        var nowPlayingInfo = [String: Any]()
        let asset = AVAsset(url: fileUrl) as AVAsset

        for metaDataItems in asset.commonMetadata {
            switch metaDataItems.commonKey!.rawValue {
            case "title":
                guard let title = metaDataItems.value as? String else {break}
                nowPlayingInfo[MPMediaItemPropertyTitle] = title
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

        if nowPlayingInfo[MPMediaItemPropertyTitle] == nil {
            nowPlayingInfo[MPMediaItemPropertyTitle] = itemsArray[indexOfCurrentItem!].fileName
        }

        let artwork: MPMediaItemArtwork!
        if #available(iOS 10.0, *) {
            artwork = MPMediaItemArtwork.init(boundsSize: imageForPlayerView.size, requestHandler: { (size) -> UIImage in
                return imageForPlayerView
            })
        } else {
            artwork = MPMediaItemArtwork.init(image: imageForPlayerView)
        }

        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.duration

        playerView.updateViewWith(text: nowPlayingInfo[MPMediaItemPropertyTitle] as! String, image: imageForPlayerView)

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

extension MusicViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let index = indexOfCurrentItem else {return}
        if index + 1 <= itemsArray.count - 1 {
            startPlay(atIndex: indexOfCurrentItem!+1)
        } else {
            player.stop()
        }
    }
}

extension MusicViewController: PlayerViewDelegate {
    func previousTrackDidTap(sender: PlayerView) {
        guard let index = indexOfCurrentItem, index-1 <= self.itemsArray.count - 1 else {
            self.startPlay(atIndex: 0)
            return
        }
        self.startPlay(atIndex: index-1)
    }

    func forwardRewindDidTap(sender: PlayerView) {
        guard let player = player else {return}
        player.currentTime = player.currentTime + TimeInterval.init(15)
    }

    func playAndPauseDidTap(sender: PlayerView) {
        guard let player = player else {
            startPlay(atIndex: 0)
            return
        }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    func backRewindDidTap(sender: PlayerView) {
        guard let player = player else {return}
        player.currentTime = player.currentTime - TimeInterval.init(15)
    }

    func nextTrackDidTap(sender: PlayerView) {
        guard let index = indexOfCurrentItem, index+1 <= self.itemsArray.count - 1 else {
            self.startPlay(atIndex: 0)
            return
        }
        self.startPlay(atIndex: index+1)
    }
}
