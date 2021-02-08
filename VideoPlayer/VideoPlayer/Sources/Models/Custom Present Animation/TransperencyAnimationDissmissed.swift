//
//  TransperencyAnimationDissmissed.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 08.02.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

final class TransperencyAnimationDissmissed: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: Constants
    private let animationDuration: TimeInterval = 0.5
    
    // MARK: Functions
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let dismissingView = transitionContext.viewController(forKey: .from)?.view else {
            return
        }
        
        //setup start present animation data
        dismissingView.alpha = 1
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: animationDuration, animations: {
            //setup finish present animation data
            dismissingView.alpha = 0
        }) { isSuccess in
            dismissingView.removeFromSuperview()
            
            transitionContext.completeTransition(isSuccess)
        }
    }
}
