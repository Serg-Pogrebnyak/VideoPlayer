//
//  OverlayView.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 29.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

/**
 Overlay view with animation
 - Author: Serg P
 - Version: 0.1
 - Date: 29.01.2020
*/

open class OverlayView: UIView, CAAnimationDelegate {

    //MARK:- private property
    private var timer: Timer!
    private var timerSecond = -1
    private var showDelay: Int! //for example after 5 sec without tap/swipe on screen snow should start
    private var imageForAnimation: UIImage!
    private var showAlways: Bool!

    //MARK:- constructors
    /**
     Add ovelay view with animation layer like snow animation
     - Parameters:
        - image: image which will animate, size shouldbe  48*48 - it's perfect size for animation
        - frame: overlay view frame
        - showAlways: don't hide animation aftre tap/swipe, default value - false
        - showDelay: delay after which should show animation (only if showAlways == false), default value - 5 sec
     - Author: Serg P
     - Version: 0.1
     - Date: 29.01.2020
    */
    init(frame: CGRect, image: UIImage, showAlways: Bool = false, showDelay delay: Int = 5) {
        super.init(frame: frame)
        if showAlways {
            self.alpha = 0.5
        }
        self.showAlways = showAlways
        self.showDelay = delay
        self.imageForAnimation = image
        self.layer.addSnowEffectLayer(image: image)
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(self)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK:- CAAnimationDelegate function
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag && (self.layer.sublayers!.first as! CAEmitterLayer).animation(forKey: "opacityAnimationForSnow") == anim { //check if finished opacity animation from snow layer then remove sublayers
            self.layer.sublayers = nil
        }
    }

    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !showAlways {
            checkAction()
        }
        return nil
    }

    //MARK: - fileprivate functions
    fileprivate func checkAction() {
        guard !(self.layer.sublayers?.isEmpty ?? true) else {return}
        let subLayer = self.layer.sublayers!.first as! CAEmitterLayer
        let hideAnimation = CABasicAnimation(keyPath: "opacity")
        hideAnimation.fromValue = 1
        hideAnimation.toValue = 0
        hideAnimation.duration = 1.5
        hideAnimation.delegate = self
        hideAnimation.fillMode = .forwards
        hideAnimation.isRemovedOnCompletion = false
        subLayer.add(hideAnimation, forKey: "opacityAnimationForSnow")

        timerSecond = showDelay
    }

    @objc fileprivate func updateTime() {
        switch timerSecond {
        case 1...showDelay:
            timerSecond = timerSecond - 1
        case 0:
            self.layer.addSnowEffectLayer(image: imageForAnimation)
            timerSecond = timerSecond - 1
        default:
            break
        }
    }
}
