//
//  EmptyVideoListView.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 31.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import Lottie

class EmptyVideoListView: UIView, AbstractNibView, EmptyAnimatedViewProtocol {

    @IBOutlet private weak var animationView: AnimationView!

    func startAnimation() {
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
    }
}
