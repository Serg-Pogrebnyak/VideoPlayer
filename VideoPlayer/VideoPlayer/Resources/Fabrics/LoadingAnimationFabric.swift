//
//  LoadingAnimationFabric.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 04.02.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import Lottie

struct LoadingAnimationFabric {
    private static let loadingAnimationSpeed: CGFloat = 1.5
    private static let successAnimationSpeed: CGFloat = 3
    private static let startLoadingFrame: CGFloat = 119
    private static let endLoadingFrame: CGFloat = 238
    private static let endSuccessFrame: CGFloat = 400
    
    //MARK: Animation functions
    static func setupLoadingAnitaion(animationView: AnimationView) {
        let loadingAnimation = Animation.named("loadingSuccessFailSpinner")
        animationView.animation = loadingAnimation
    }
    
    static func runLoadingAnimation(animationView: AnimationView) {
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.animationSpeed = loadingAnimationSpeed
        animationView.play(fromFrame: startLoadingFrame,
                           toFrame: endLoadingFrame,
                           loopMode: .loop)
    }
    
    static func runSuccessAnimation(animationView: AnimationView) {
        animationView.animationSpeed = successAnimationSpeed
        animationView.play(toFrame: endSuccessFrame,
                           loopMode: .playOnce)
    }
}
