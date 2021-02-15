//
//  MusicInteractor.swift
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

protocol MusicBusinessLogic {
    func fetchLocalItems(request: Music.FetchLocalItems.Request)
    func startPlayOrDownload(request: Music.StartPlayOrDownload.Request)
    func updatePlayingSongInfo(request: Music.UpdatePlayingSongInfo.Request)
    func removeMediaItem(request: Music.DeleteMediaItem.Request)
    func findMediaItems(request: Music.FindMediaItems.Request)
    
    //player functions
    func rewind(request: Music.Rewind.Request) -> MPRemoteCommandHandlerStatus
    func pause(request: Music.Pause.Request) -> MPRemoteCommandHandlerStatus
    func play(request: Music.Play.Request) -> MPRemoteCommandHandlerStatus
    func nextTrack(request: Music.NextTrack.Request) -> MPRemoteCommandHandlerStatus
    func previousTrack(request: Music.PreviousTrack.Request) -> MPRemoteCommandHandlerStatus
}

protocol MusicDataStore {
    
}

final class MusicInteractor: MusicBusinessLogic, MusicDataStore {
    
    var presenter: MusicPresentationLogic?
    //workerks
    private var playWorker: PlayMusicWorker?
    
    //business logic variables
    private(set) var itemsSet = Set<MusicOrVideoItem>()
    private var itemsArray = [MusicOrVideoItem]()
    private var indexOfItemForPlay = 0
    
    // MARK: Do something
    func fetchLocalItems(request: Music.FetchLocalItems.Request) {
        itemsSet = CoreManager.shared.getMediaItems()
        itemsArray = Array(itemsSet).sorted { $0.addedDate > $1.addedDate }
        let response = Music.FetchLocalItems.Response(musicItems: itemsArray)
        presenter?.showMusicItems(response: response)
    }
    
    func startPlayOrDownload(request: Music.StartPlayOrDownload.Request) {
        guard   let indexOfItem = (itemsArray.firstIndex { $0.localId == request.localId }),
                containLocal(item: itemsArray[indexOfItem])
        else { return }
        
        indexOfItemForPlay = indexOfItem
        let itemForPlay = itemsArray[indexOfItem]
        
        var response = Music.StartPlayOrDownload.Response(playerButtonState: isEnabledPlayerButtons(indexOfSong: indexOfItem))
        if itemForPlay.isNew {
            itemsArray[indexOfItem].isNew = false
            saveChanges()
            response.musicItem = itemsArray[indexOfItem]
            response.atIndex = indexOfItem
        }
        
        presenter?.unnewMusicItem(response: response)
        
        let playWorker = PlayMusicWorker()
        self.playWorker = playWorker
        playWorker.playSongByURL(url: itemForPlay.localFileURL,
                                 songTitle: itemsArray[indexOfItem].displayFileName)
        playWorker.delegate = self
    }
    
    func removeMediaItem(request: Music.DeleteMediaItem.Request) {
        let removedObjectOptional = itemsSet.first{ $0.localId == request.localId }
        guard let removedObject = removedObjectOptional else { return }
        
        itemsSet.remove(removedObject)
        CoreManager.shared.coreManagerContext.delete(removedObject)
        saveChanges()
        
        FileManager.default.removeFileFromApplicationSupportDirectory(withName: removedObject.fileNameInStorage)
        
        let response = Music.DeleteMediaItem.Response(musicItems: itemsArray)
        presenter?.updateMusicItemsAfterDeleting(response: response)
    }
    
    func findMediaItems(request: Music.FindMediaItems.Request) {
        let searchText = request.searchText
        var resultArray = Array(itemsSet).sorted { $0.addedDate > $1.addedDate }
        
        if !searchText.isEmpty  {
            resultArray = itemsSet.filter { $0.displayFileName.contains(searchText) }
            
        }
        itemsArray = resultArray
        let response = Music.FindMediaItems.Response(musicItems: resultArray)
        presenter?.updateMusicItemsAfterSearch(response: response)
    }
    
    func updatePlayingSongInfo(request: Music.UpdatePlayingSongInfo.Request) {
        playWorker?.callDelegateWithUpdatedInfoIfPossible()
    }
    
    // MARK: Player functions
    func rewind(request: Music.Rewind.Request) -> MPRemoteCommandHandlerStatus {
        guard let playMusicWorker = playWorker else { return .commandFailed }
        
        return playMusicWorker.rewind(toTime: request.rewindTime)
    }
    
    func pause(request: Music.Pause.Request) -> MPRemoteCommandHandlerStatus {
        guard let playMusicWorker = playWorker else { return .commandFailed }
        
        return playMusicWorker.pause()
    }
    
    func play(request: Music.Play.Request) -> MPRemoteCommandHandlerStatus {
        guard let playMusicWorker = playWorker else { return .commandFailed }
        
        return playMusicWorker.play()
    }
    
    func nextTrack(request: Music.NextTrack.Request) -> MPRemoteCommandHandlerStatus {
        let nextIndexOfItemForPlay = indexOfItemForPlay + 1
        
        guard   itemsArray.indices.contains(nextIndexOfItemForPlay),
                containLocal(item: itemsArray[nextIndexOfItemForPlay]),
                let playWorker = playWorker
        else { return .commandFailed }
        
        indexOfItemForPlay = nextIndexOfItemForPlay
        let itemForPlay = itemsArray[nextIndexOfItemForPlay]
        let resultOfStartPlay = playWorker.playSongByURL(url: itemForPlay.localFileURL,
                                                         songTitle: itemForPlay.displayFileName)
        
        let response = Music.NextTrack.Response(playerButtonState: isEnabledPlayerButtons(indexOfSong: nextIndexOfItemForPlay))
        presenter?.prepareDataAfterTapOnNextTrackButton(response: response)
        
        return resultOfStartPlay ? .success : .commandFailed
    }
    
    func previousTrack(request: Music.PreviousTrack.Request) -> MPRemoteCommandHandlerStatus {
        let nextIndexOfItemForPlay = indexOfItemForPlay - 1
        
        guard   itemsArray.indices.contains(nextIndexOfItemForPlay),
                containLocal(item: itemsArray[nextIndexOfItemForPlay]),
                let playWorker = playWorker
        else { return .commandFailed }
        
        indexOfItemForPlay = nextIndexOfItemForPlay
        let itemForPlay = itemsArray[nextIndexOfItemForPlay]
        let resultOfStartPlay = playWorker.playSongByURL(url: itemForPlay.localFileURL,
                                                         songTitle: itemForPlay.displayFileName)
        
        let response = Music.PreviousTrack.Response(playerButtonState: isEnabledPlayerButtons(indexOfSong: nextIndexOfItemForPlay))
        presenter?.prepareDataAfterTapOnPreviousTrackButton(response: response)
        
        return resultOfStartPlay ? .success : .commandFailed
    }
    
    // MARK: Private functions
    private func saveChanges() {
        CoreManager.shared.saveContext()
    }
    
    private func containLocal(item: MusicOrVideoItem) -> Bool {
        let fileUrl = item.localFileURL
        
        guard FileManager.default.fileExists(atPath: fileUrl.path) else {
            print("❌ file not found on device")
            return false
        }
        
        return true
    }
    
    private func isEnabledPlayerButtons(indexOfSong: Int) -> Music.PlayerButtonState {
        let playPauseButton = true
        
        var previousTrackButton: Bool!
        if indexOfSong == 0 {
            previousTrackButton = false
        } else {
            previousTrackButton = true
        }
        
        var nextTrackButton: Bool!
        if indexOfSong == itemsArray.count-1 {
            nextTrackButton = false
        } else {
            nextTrackButton = true
        }
        
        return Music.PlayerButtonState(previousTrack: previousTrackButton,
                                       playPause: playPauseButton,
                                       nextTrack: nextTrackButton)
    }
}

extension MusicInteractor: PlayMusicWorkerDelegate {
    func didFinishPlaySong() {
        
    }
    
    func updatedPlayingStateAndInfo(playingInfo: Music.UpdatePlayingSongInfo.SongInfoForDisplay) {
        var response = Music.UpdatePlayingSongInfo.Response(info: playingInfo)
        presenter?.updatePlayingSongInfo(response: response)
    }
}
