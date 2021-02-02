//
//  MusicPresenter.swift
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

protocol MusicPresentationLogic {
    func showMusicItems(response: Music.FetchLocalItems.Response)
    func unnewMusicItem(response: Music.StartPlayOrDownload.Response)
    func updateMusicItemsAfterDeleting(response: Music.DeleteMediaItem.Response)
    func updatePlayingSongInfo(response: Music.UpdatePlayingSongInfo.Response)
}

class MusicPresenter: MusicPresentationLogic {
    
    weak var viewController: MusicDisplayLogic?
    
    // MARK: Show all music items
    func showMusicItems(response: Music.FetchLocalItems.Response) {
        let responseArray = Array(response.musicItems)
        let musicDisplayDataArray = responseArray.map{Music.MusicDisplayData(fileName: $0.displayFileName,
                                                                             isNew: $0.isNew,
                                                                             localId: $0.localId)
        }
        let viewModel = Music.FetchLocalItems.ViewModel(musicDisplayDataArray: musicDisplayDataArray)
        viewController?.displayMusicItemsArray(viewModel: viewModel )
    }
    
    func unnewMusicItem(response: Music.StartPlayOrDownload.Response) {
        let musicDisplayData = Music.MusicDisplayData(fileName: response.musicItem.displayFileName,
                                                      isNew: response.musicItem.isNew,
                                                      localId: response.musicItem.localId)
        let viewModel = Music.StartPlayOrDownload.ViewModel(musicItem: musicDisplayData,
                                                            atIndex: response.atIndex)
        viewController?.unnewMusicItem(viewModel: viewModel)
    }
    
    func updatePlayingSongInfo(response: Music.UpdatePlayingSongInfo.Response) {
        let viewModel = Music.UpdatePlayingSongInfo.ViewModel(info: response.info)
        viewController?.updatePlaynigSongInfo(viewModel: viewModel)
    }
    
    func updateMusicItemsAfterDeleting(response: Music.DeleteMediaItem.Response) {
        let responseArray = Array(response.musicItems)
        let musicDisplayDataArray = responseArray.map{Music.MusicDisplayData(fileName: $0.displayFileName,
                                                                             isNew: $0.isNew,
                                                                             localId: $0.localId)
        }
        let viewModel = Music.DeleteMediaItem.ViewModel(musicDisplayDataArray: musicDisplayDataArray)
        viewController?.displayMusicItemsArrayAfterDeleting(viewModel: viewModel )
    }
}
