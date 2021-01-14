//
//  PlayMusicWorker.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 14.01.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import Foundation
import AVFoundation

class PlayMusicWorker {
    private var player: AVPlayer? = nil
    
    func playSongByURL(url: URL) {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch  {
            print("Audio session failed")
        }
        
        let playerItem = AVPlayerItem(url: url)
        //NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlay), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        player = AVPlayer.init(playerItem: playerItem)
        //player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        player?.play()
    }
}
