//
//  PlayMusicWorker.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 14.01.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlayMusicWorkerDelegate: class {
    func didFinishPlaySong()
    func updatedPlayingState(state: PlayMusicWorker.PlayingState)
}

class PlayMusicWorker: NSObject {
    
    enum PlayingState {
        case playing
        case stopped
    }
    
    weak var delegate: PlayMusicWorkerDelegate?
    
    private var player: AVPlayer? = nil
    
    func playSongByURL(url: URL) -> Bool {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch  {
            return false
        }
        
        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlay),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        player = AVPlayer.init(playerItem: playerItem)
        player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        player?.play()
        return true
    }
    
    @objc private func playerDidFinishPlay() {
        delegate?.didFinishPlaySong()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let currentItem = object as? AVPlayer else {return}
        
        if currentItem.rate > 0.0 {
            delegate?.updatedPlayingState(state: .playing)
            //playerView.changePlayButtonIcon(playNow: true)
            //nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        } else {
            delegate?.updatedPlayingState(state: .stopped)
            //playerView.changePlayButtonIcon(playNow: false)
            //nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        }
        //updateInformationOnLockScreen()
    }
}
