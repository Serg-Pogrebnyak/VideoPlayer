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
    
    private let animationSpeed: CGFloat = 1.5
    private let startLoadingFrame: CGFloat = 119
    private let endLoadingFrame: CGFloat = 238
    private let endSuccessFrame: CGFloat = 400
    
    private var currentSyncState: SyncMusic.Sync.SyncState!
    
    func setupDataInView(viewModel: SyncMusic.Sync.SyncDisplayModel) {
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
            startGeneralLoadingAnimation()
        case .success:
            startGeneralSuccessAnimation()
        case .failed:
            //TODO: add implementation for failed
            return
        case .none:
            return
        }
    }
    
    private func startGeneralLoadingAnimation() {
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.animationSpeed = animationSpeed
        animationView.play(fromFrame: startLoadingFrame,
                           toFrame: endLoadingFrame,
                           loopMode: .loop)
    }
    
    private func startGeneralSuccessAnimation() {
        animationView.animationSpeed = 3
        animationView.play(toFrame: endSuccessFrame,
                           loopMode: .playOnce)
    }
}
