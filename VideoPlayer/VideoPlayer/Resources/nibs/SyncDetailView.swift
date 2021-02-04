//
//  SyncDetailView.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 04.02.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import Lottie

protocol SyncDetailViewProtocol: class {
    func setupDataInView(viewModel: SyncMusic.Sync.SyncDisplayModel)
    func updateSyncState(byState state: SyncMusic.Sync.SyncState)
}

final class SyncDetailView: UIView, SyncDetailViewProtocol, AbstractNibView {

    // MARK: Outlets
    @IBOutlet private weak var animationView: AnimationView!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var descLabelHeight: NSLayoutConstraint!
    
    private var currentSyncState: SyncMusic.Sync.SyncState!
    
    func setupDataInView(viewModel: SyncMusic.Sync.SyncDisplayModel) {
        LoadingAnimationFabric.setupLoadingAnitaion(animationView: animationView)
        
        descLabel.text = viewModel.description
        descLabel.sizeToFit()
        descLabelHeight.constant = descLabel.bounds.height
        
        self.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: descLabel.bounds.height)
        
        updateSyncState(byState: viewModel.currentSyncState)
    }
    
    func updateSyncState(byState state: SyncMusic.Sync.SyncState) {
        guard currentSyncState == nil || currentSyncState == .loading else { return }
        
        currentSyncState = state
        
        switch currentSyncState {
        case .loading:
            LoadingAnimationFabric.runLoadingAnimation(animationView: animationView)
        case .success:
            LoadingAnimationFabric.runSuccessAnimation(animationView: animationView)
        case .failed:
            //TODO: add implementation for failed
            return
        case .none:
            return
        }
    }
}
