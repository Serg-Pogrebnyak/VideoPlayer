//
//  MusicModels.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 13.01.2021.
//  Copyright (c) 2021 Sergey Pohrebnuak. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import MediaPlayer

enum Music {
    // MARK: Use cases
    //FIXME: можно ли делать так?
    struct MusicDisplayData {
        var fileName: String
        var isNew: Bool
        var localId: String
    }
    struct PlayerButtonState {
        var previousTrack: Bool
        var playPause: Bool
        var nextTrack: Bool
    }
    
    enum FetchLocalItems {
        struct Request {
        }
        
        struct Response {
            var musicItems: [MusicOrVideoItem]
        }
        
        struct ViewModel {
            var musicDisplayDataArray: [MusicDisplayData]
        }
    }
    
    enum StartPlayOrDownload {
        struct Request {
            let localId: String
        }
        
        struct Response {
            var musicItem: MusicOrVideoItem?
            var atIndex: Int?
            
            var playerButtonState: PlayerButtonState
        }
        
        struct ViewModel {
            var musicItem: MusicDisplayData?
            var atIndex: Int?
            
            var playerButtonState: PlayerButtonState
        }
    }
    
    enum DeleteMediaItem {
        struct Request {
            let localId: String
        }
        
        struct Response {
            var musicItems: [MusicOrVideoItem]
        }
        
        struct ViewModel {
            var musicDisplayDataArray: [MusicDisplayData]
        }
    }
    
    enum FindMediaItems {
        struct Request {
            let searchText: String
        }
        
        struct Response {
            var musicItems: [MusicOrVideoItem]
        }
        
        struct ViewModel {
            var musicDisplayDataArray: [MusicDisplayData]
        }
    }
    
    enum UpdatePlayingSongInfo {
        
        struct SongInfoForDisplay {
            var playerRate: Float
            var isPlaying: Bool {
                return playerRate != 0
            }
            var imageForPlayerView: UIImage! = UIImage.init(named: "mp3")
            var artist: String?
            var album: String?
            var title: String?
            var songDuration: Double
            var elapsedPlaybackTime: Double
            
            func getLikeDictForSystem() -> [String: Any] {
                var nowPlayingInfo = [String: Any]()
        
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playerRate
        
                nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            
                nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
    
                nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
                let artwork = MPMediaItemArtwork.init(boundsSize: imageForPlayerView.size, requestHandler: { (size) -> UIImage in
                    return self.imageForPlayerView
                })
        
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = songDuration
        
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedPlaybackTime
                
                return nowPlayingInfo
            }
        }
        
        struct Request {
        }
        
        struct Response {
            var info: SongInfoForDisplay
        }
        
        struct ViewModel {
            var info: SongInfoForDisplay
        }
    }
    
    enum Rewind {
        struct Request {
            let rewindTime: CMTime
        }
    }
    
    enum Pause {
        struct Request {
        }
    }
    
    enum Play {
        struct Request {
        }
    }
    
    enum NextTrack {
        struct Request {
        }
        
        struct Response {
            var playerButtonState: PlayerButtonState
        }
        
        struct ViewModel {
            var playerButtonState: PlayerButtonState
        }
    }
}
