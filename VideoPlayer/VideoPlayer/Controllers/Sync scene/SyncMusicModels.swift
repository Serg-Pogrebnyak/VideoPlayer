//
//  SyncMusicModels.swift
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

enum SyncMusic {
    // MARK: Use cases
    
    enum Sync {
        enum SyncState {
            case loading
            case success
            case failed
        }
        
        struct SyncProcess {
            var fetchFromLocalDB = SyncState.loading {
                didSet {
                    didSetFunction(state: fetchFromLocalDB)
                }
            }
            var fetchFromCloud = SyncState.loading {
                didSet {
                    didSetFunction(state: fetchFromCloud)
                }
            }
            var fetchFromLocalStorage = SyncState.loading {
               didSet {
                   didSetFunction(state: fetchFromLocalStorage)
               }
            }
            var merge = SyncState.loading {
               didSet {
                   didSetFunction(state: merge)
               }
           }
            
            var allDone = SyncState.loading //didn't set on a straight line, this value like computed by self
            
            
            private var counter = 0
            private var syncSteps = 3 //when counter equal to this value all sync is compleate
            
            //MARK: Private functions
            private mutating func didSetFunction(state: SyncState) {
                switch fetchFromLocalDB {
                case .loading:
                    return
                case .success:
                    somethingSuccess()
                case .failed:
                    somethingFailed()
                }
            }
            
            private mutating func somethingSuccess() {
                counter += 1
                if counter == syncSteps {
                    allDone = .success
                }
            }
            
            private mutating func somethingFailed() {
                allDone = .failed
            }
        }
        
        struct SyncDisplayModel {
            let currentSyncState: SyncState
            let description: String
        }
        
        struct Request {
        }
        
        struct Response {
            let syncState: SyncProcess
        }
        
        struct ViewModel {
            let arrayOfSyncProcessModel: [SyncDisplayModel]
        }
    }
}
