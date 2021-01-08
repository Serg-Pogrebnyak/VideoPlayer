//
//  EmptyMusicListView.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 04.02.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import Lottie

class EmptyMusicListView: UIView, AbstractNibView, EmptyAnimatedViewProtocol {

    @IBOutlet private weak var animationView: AnimationView!

    func startAnimation() {
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.loopMode = .autoReverse
        animationView.play()
    }
}
