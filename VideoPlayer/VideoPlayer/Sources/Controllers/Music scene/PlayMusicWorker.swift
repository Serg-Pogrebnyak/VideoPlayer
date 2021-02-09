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
    func updatedPlayingStateAndInfo(playingInfo: Music.UpdatePlayingSongInfo.SongInfoForDisplay)
}

class PlayMusicWorker {
    
    weak var delegate: PlayMusicWorkerDelegate?
    
    private var player: AVPlayer? = nil
    private var playingFileURL: URL? = nil
    // isRewindingNow property uses for ignore player time observing while player didn't rewind song, because in otherwise function call with wrong data (future time)
    private var isRewindingNow = false
    
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
                                        using:
        { [weak self] (time) in
            guard   let self = self,
                    !self.isRewindingNow
            else {
                return
            }
            
            self.playerTimeChanged(time)
        })
        player?.play()
        return true
    }
    
    func rewind(toTime time: CMTime) -> MPRemoteCommandHandlerStatus {
        guard   let player = player,
                let _ = player.currentItem
        else {
            return .commandFailed
        }
        
        isRewindingNow = true
        player.seek(to: time) { [weak self] _ in
            self?.callDelegateWithUpdatedInfoIfPossible()
            self?.isRewindingNow = false
        }
        return .success
    }
    
    func callDelegateWithUpdatedInfoIfPossible() {
        guard let player = player else {return}
        playerTimeChanged(player.currentTime())
    }
    
    @objc private func playerDidFinishPlay() {
        delegate?.didFinishPlaySong()
    }
    
    private func playerTimeChanged(_ time: CMTime) {
        guard let player = player else {return}
        
        let songDuration: Double = player.currentItem?.asset.duration.seconds ?? 0
        var nowPlayingInfo = Music.UpdatePlayingSongInfo.SongInfoForDisplay(playerRate: player.rate,
                                                                            songDuration: songDuration,
                                                                            elapsedPlaybackTime: time.seconds)
        
        if let songUrl = playingFileURL {
            let asset = AVAsset(url: songUrl) as AVAsset

            for metaDataItems in asset.commonMetadata {
                switch metaDataItems.commonKey {
                case AVMetadataKey.commonKeyArtist:
                    guard let artist = metaDataItems.value as? String else {break}
                    nowPlayingInfo.artist = artist
                case AVMetadataKey.commonKeyAlbumName:
                    guard let album = metaDataItems.value as? String else {break}
                    nowPlayingInfo.album = album
                case AVMetadataKey.commonKeyArtwork:
                    guard   let imageData = metaDataItems.value as? Data,
                            let image = UIImage(data: imageData) else {break}
                    nowPlayingInfo.imageForPlayerView = image
                default:
                    continue
                }
            }
        }

        delegate?.updatedPlayingStateAndInfo(playingInfo: nowPlayingInfo)
    }
}
