//
//  SyncMusicViewController.swift
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
import Lottie

protocol SyncMusicDisplayLogic: class {
    func displaySyncState(viewModel: SyncMusic.Sync.ViewModel)
}

final class SyncMusicViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet private weak var popUpContainerView: UIView!
    @IBOutlet private weak var generalLoadingBorderView: UIView!
    @IBOutlet private weak var generalLoadingAnimationView: AnimationView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var progressPerStepStackView: UIStackView!
    @IBOutlet private weak var progressPerStepStackViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var closeButtonHeight: NSLayoutConstraint!
    
    
    //MARK: Variables
    private var interactor: SyncMusicBusinessLogic?
    private var arrayOfSyncDetailView = [SyncDetailViewProtocol]()
    
    //MARK: Constants
    private let generalViewCornerRadius: CGFloat = 20
    private let spacingBetweenDetailView: CGFloat = 10
    private let showCloseButtonAnimationDuration: TimeInterval = 1
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCleanCycle()
        configureUI()
        LoadingAnimationFabric.setupLoadingAnitaion(animationView: generalLoadingAnimationView)
        LoadingAnimationFabric.runLoadingAnimation(animationView: generalLoadingAnimationView)
    }
    
    //MARK: Actions
    @IBAction private func didTapCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    //MARK: Setup
    private func configureUI() {
        titleLabel.text = "Synchronization"
        descriptionLabel.text = "Application synchronize your media files"
        descriptionLabel.sizeToFit()
        descriptionLabelHeight.constant = descriptionLabel.bounds.height
        
        closeButton.setTitle("DONE", for: .normal)
        ButtonFabric.makeBoldColorButton(closeButton)
        closeButton.isHidden = true
        closeButton.sizeToFit()
        closeButtonHeight.constant = closeButton.bounds.height
        
        popUpContainerView.layer.cornerRadius = generalViewCornerRadius
        generalLoadingBorderView.layer.cornerRadius = generalLoadingBorderView.layer.bounds.width/2
        generalLoadingAnimationView.layer.cornerRadius = generalLoadingAnimationView.layer.bounds.width/2
    }
    
    private func setupCleanCycle() {
        let viewController = self
        let interactor = SyncMusicInteractor()
        let presenter = SyncMusicPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    private func animatedDisplayCloseButton() {
        closeButton.alpha = 0
        closeButton.isHidden = false
        
        UIView.animate(withDuration: showCloseButtonAnimationDuration) { [weak self] in
            self?.closeButton.alpha = 1
        }
    }
}

extension SyncMusicViewController: SyncMusicDisplayLogic {
    func displaySyncState(viewModel: SyncMusic.Sync.ViewModel) {
        if  arrayOfSyncDetailView.isEmpty ||
            viewModel.arrayOfSyncProcessModel.count != arrayOfSyncDetailView.count
        {
            setupDetailViews(viewModel)
        } else {
            updateDeilViews(viewModel)
        }
    }
    
    private func setupDetailViews(_ viewModel: SyncMusic.Sync.ViewModel) {
        arrayOfSyncDetailView.removeAll()
        progressPerStepStackView.removeAllArrangedSubviews()
        
        var totalHeightOfDetailViews: CGFloat = 0
        for viewData in viewModel.arrayOfSyncProcessModel {
            let syncDetailView = SyncDetailView.loadFromNib()
            syncDetailView.setupDataInView(viewModel: viewData)
            totalHeightOfDetailViews += syncDetailView.bounds.height
            progressPerStepStackView.addArrangedSubview(syncDetailView)
            arrayOfSyncDetailView.append(syncDetailView)
        }
        
        
        let totalSpacing = spacingBetweenDetailView * CGFloat(viewModel.arrayOfSyncProcessModel.count - 1)
        progressPerStepStackViewHeight.constant = totalHeightOfDetailViews + totalSpacing
    }
    
    private func updateDeilViews(_ viewModel: SyncMusic.Sync.ViewModel) {
        for (index, detailView) in arrayOfSyncDetailView.enumerated() {
            let viewData = viewModel.arrayOfSyncProcessModel[index]
            detailView.updateSyncState(byState: viewData.currentSyncState)
        }
        
        updateGeneralLoadingAnimation(byState: viewModel.generalSyncState)
    }
    
    private func updateGeneralLoadingAnimation(byState state: SyncMusic.Sync.SyncState) {
        switch state {
        case .loading:
            return
        case .success:
            animatedDisplayCloseButton()
            LoadingAnimationFabric.runSuccessAnimation(animationView: generalLoadingAnimationView)
        case .failed:
            //TODO: add implementation for failed
            return
        }
    }
}
