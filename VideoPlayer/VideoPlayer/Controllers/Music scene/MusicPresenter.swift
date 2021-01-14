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
}

class MusicPresenter: MusicPresentationLogic {
    
    weak var viewController: MusicDisplayLogic?
    
    // MARK: Show all music items
    func showMusicItems(response: Music.FetchLocalItems.Response) {
        let responseArray = Array(response.musicItems)
        let musicDisplayDataArray = responseArray.map{Music.MusicDisplayData(fileName: $0.fileName,
                                                                             isNew: $0.isNew)
        }
        let viewModel = Music.FetchLocalItems.ViewModel(musicDisplayDataArray: musicDisplayDataArray)
        viewController?.displayMusicItemsArray(viewModel: viewModel )
    }
    
    func unnewMusicItem(response: Music.StartPlayOrDownload.Response) {
        let musicDisplayData = Music.MusicDisplayData(fileName: response.musicItem.fileName,
                                                      isNew: response.musicItem.isNew)
        let viewModel = Music.StartPlayOrDownload.ViewModel(musicItem: musicDisplayData,
                                                            atIndex: response.atIndex)
        viewController?.unnewMusicItem(response: viewModel)
    }
}
