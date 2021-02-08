//
//  TransperencyAnimationPresent.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 08.02.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

final class TransperencyAnimationPresent: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: Constants
    private let animationDuration: TimeInterval = 0.5
    
    // MARK: Functions
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentingView = transitionContext.viewController(forKey: .to)?.view else {
            return
        }
        
        transitionContext.containerView.addSubview(presentingView)
        
        let size = CGSize(width: UIScreen.main.bounds.width,
                          height: UIScreen.main.bounds.height)
        
        presentingView.frame = CGRect(origin: .zero, size: size)
        
        //setup start present animation data
        presentingView.alpha = 0
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: animationDuration, animations: {
            //setup finish present animation data
            presentingView.alpha = 1
        }) { isSuccess in
            transitionContext.completeTransition(isSuccess)
        }
    }
}
