//
//  MusicRouter.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 03.02.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

protocol MusicRouterInput {
    func routeToSyncMusicViewController()
}

protocol MusicDataPassing {
    var dataStore: MusicDataStore? { get }
}

final class MusicRouter: MusicRouterInput, MusicDataPassing {

    // MARK: Variables
    weak var viewController: UIViewController?
    var dataStore: MusicDataStore?
    
    private var customPresentAnimation: CustomPresentAnimation
    
    // MARK: Сonstructor
    init() {
        customPresentAnimation = CustomPresentAnimation(presentDelegate: TransperencyAnimationPresent(),
                                                        dismissDelegate: TransperencyAnimationDissmissed())
    }
    
    // MARK: Routing
    func routeToSyncMusicViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard   let destinationVC = storyboard.instantiateViewController(withIdentifier: String(describing:         SyncMusicViewController.self)) as? SyncMusicViewController,
                var destinationDS = destinationVC.router?.dataStore,
                let dataStore = dataStore,
                let viewController = viewController
        else { return }
        
        destinationVC.modalPresentationStyle = .custom
        destinationVC.transitioningDelegate = customPresentAnimation
        passDataToSyncMusicViewController(source: dataStore, destination: &destinationDS)
        navigateToSyncMusicViewController(source: viewController, destination: destinationVC)
    }
    
    // MARK: Passing data
    private func passDataToSyncMusicViewController(source: MusicDataStore, destination: inout SyncMusicDataStore) {
        destination.delegate = viewController as? SyncMusicViewControllerDelegate
    }
    
    // MARK: Navigation
    private func navigateToSyncMusicViewController(source: UIViewController, destination: SyncMusicViewController) {
        source.present(destination,
                       animated: true,
                       completion: nil)
    }
}
