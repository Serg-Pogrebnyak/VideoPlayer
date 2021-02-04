//
//  SyncMusicInteractor.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 03.02.2021.
//  Copyright (c) 2021 Sergey Pohrebnuak. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SyncMusicBusinessLogic {
    func sync(request: SyncMusic.Sync.Request)
}

final class SyncMusicInteractor: SyncMusicBusinessLogic {
    
    var presenter: SyncMusicPresentationLogic?
    
    private var syncState = SyncMusic.Sync.SyncProcess()
    private var fetchWorker: FetchFromLocalStorageWorker?
    
    private let musicExtension = ".mp3"
    
    // MARK: Business Logic
    func sync(request: SyncMusic.Sync.Request) {
        syncState = SyncMusic.Sync.SyncProcess()
        callPresenter()

        fetchFromLocalDB()
    }
    
    private func fetchFromLocalDB() {
        fetchWorker = FetchFromLocalStorageWorker()
        fetchWorker?.fetch(byTypeExtension: musicExtension)
        syncState.fetchFromLocalDB = .success
        
        callPresenter()
        
        fetchFromCloud()
    }
    
    private func fetchFromCloud() {
        syncState.fetchFromCloud = .success
        
        callPresenter()
        
        fetchFromLocalStorageNewItems()
    }
    
    private func fetchFromLocalStorageNewItems() {
        syncState.fetchFromLocalStorage = .success
        
        callPresenter()
        
        updateLocalDB()
    }
    
    private func updateLocalDB() {
        syncState.merge = .success
        
        callPresenter()
    }
    
    private func callPresenter() {
        let response = SyncMusic.Sync.Response(syncState: syncState)
        presenter?.updateSyncInfo(response: response)
    }
}
