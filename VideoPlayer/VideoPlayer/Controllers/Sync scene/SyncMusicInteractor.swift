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
    func doSomething(request: SyncMusic.Something.Request)
}

final class SyncMusicInteractor: SyncMusicBusinessLogic {
    
    var presenter: SyncMusicPresentationLogic?
    var worker: SyncMusicWorker?
    
    // MARK: Business Logic
    func doSomething(request: SyncMusic.Something.Request) {
        worker = SyncMusicWorker()
        worker?.doSomeWork()
        
        let response = SyncMusic.Something.Response()
        presenter?.presentSomething(response: response)
    }
}
