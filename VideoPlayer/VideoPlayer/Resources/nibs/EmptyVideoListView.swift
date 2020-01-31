//
//  EmptyVideoListView.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 31.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import Lottie

class EmptyVideoListView: UIView, AbstractNibView {

    fileprivate let animationView = AnimationView()

    override func layoutSubviews() {
        super.layoutSubviews()
        animationView.center = self.center
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        animationView.frame = CGRect(x: 0, y: 0, width: 144, height: 96)
        animationView.center = self.center
        animationView.animation = Animation.named("emtyPopcornBox")
        animationView.contentMode = .scaleToFill
        self.addSubview(animationView)
        animationView.play()
    }
}
