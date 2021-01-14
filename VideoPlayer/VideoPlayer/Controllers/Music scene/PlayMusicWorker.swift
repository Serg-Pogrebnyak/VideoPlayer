//
//  PlayMusicWorker.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 14.01.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

protocol PlayMusicWorkerDelegate: class {
    func didFinishPlaySong()
    func updatedPlayingStateAndInfo(playingInfo: [String: Any])
}

class PlayMusicWorker {
    
    weak var delegate: PlayMusicWorkerDelegate?
    
    private var player: AVPlayer? = nil
    private var playingFileURL: URL? = nil
    
    func playSongByURL(url: URL) -> Bool {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch  {
            return false
        }
        
        playingFileURL = url
        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlay),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        player = AVPlayer.init(playerItem: playerItem)
        let intervalForUpdate = CMTime(seconds: 1, preferredTimescale: 1)
        player?.addPeriodicTimeObserver(forInterval: intervalForUpdate,
                                        queue: .main,
                                        using: { [weak self] (time) in
            self?.playerTimeChanged(time)
        })
        player?.play()
        return true
    }
    
    func callDelegateWithUpdatedInfoIfPossible() {
        guard let player = player else {return}
        playerTimeChanged(player.currentTime())
    }
    
    @objc private func playerDidFinishPlay() {
        delegate?.didFinishPlaySong()
    }
    
    private func playerTimeChanged(_ time: CMTime) {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
        
        var imageForPlayerView: UIImage! = UIImage.init(named: "mp3")
        
        if let songUrl = playingFileURL {
            let asset = AVAsset(url: songUrl) as AVAsset

            for metaDataItems in asset.commonMetadata {
                switch metaDataItems.commonKey {
                case AVMetadataKey.commonKeyArtist:
                    guard let artist = metaDataItems.value as? String else {break}
                    nowPlayingInfo[MPMediaItemPropertyArtist] = artist
                case AVMetadataKey.commonKeyAlbumName:
                    guard let album = metaDataItems.value as? String else {break}
                    nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
                case AVMetadataKey.commonKeyArtwork:
                    guard   let imageData = metaDataItems.value as? Data,
                            let image = UIImage(data: imageData) else {break}
                    imageForPlayerView = image
                default:
                    continue
                }
            }
            
            nowPlayingInfo[MPMediaItemPropertyTitle] = songUrl.lastPathComponent
        }
        
        let artwork = MPMediaItemArtwork.init(boundsSize: imageForPlayerView.size, requestHandler: { (size) -> UIImage in
            return imageForPlayerView
        })

        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.currentItem?.asset.duration.stringSeconds
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time.stringSeconds

        delegate?.updatedPlayingStateAndInfo(playingInfo: nowPlayingInfo)
    }
}
