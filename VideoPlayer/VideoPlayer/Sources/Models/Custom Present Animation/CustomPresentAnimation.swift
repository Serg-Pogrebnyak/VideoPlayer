//
//  CustomPresentAnimation.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 08.02.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

open class CustomPresentAnimation: NSObject, UIViewControllerTransitioningDelegate {
    
    private var presentDelegate: UIViewControllerAnimatedTransitioning
    private var dismissDelegate: UIViewControllerAnimatedTransitioning
    
    init(presentDelegate: UIViewControllerAnimatedTransitioning, dismissDelegate: UIViewControllerAnimatedTransitioning) {
        self.presentDelegate = presentDelegate
        self.dismissDelegate = dismissDelegate
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentDelegate
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissDelegate
    }
}
