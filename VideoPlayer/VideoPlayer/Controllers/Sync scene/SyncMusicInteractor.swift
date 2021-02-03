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
    
    // MARK: Business Logic
    func sync(request: SyncMusic.Sync.Request) {
        syncState = SyncMusic.Sync.SyncProcess()
        fetchFromLocalDB()
    }
    
    private func fetchFromLocalDB() {
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
