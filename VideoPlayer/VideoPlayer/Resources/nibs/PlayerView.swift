//
//  PlayerView.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 20.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

protocol PlayerViewDelegate {
    func previousTrackDidTap(sender: PlayerView)
    func backRewindDidTap(sender: PlayerView)
    func playAndPauseDidTap(sender: PlayerView)
    func forwardRewindDidTap(sender: PlayerView)
    func nextTrackDidTap(sender: PlayerView)
}

extension PlayerViewDelegate {
    func backRewindDidTap(sender: PlayerView) {}
    func forwardRewindDidTap(sender: PlayerView) {}
}

class PlayerView: UIView {

    var delegat: PlayerViewDelegate?

    @IBOutlet fileprivate var backgroundView: UIView!
    @IBOutlet fileprivate weak var playerLabel: UILabel!
    @IBOutlet fileprivate weak var playAndPauseButton: UIButton!
    @IBOutlet fileprivate weak var trackImage: UIImageView!

    fileprivate var animator = UIViewPropertyAnimator()
    //animation property
    fileprivate var shouldBeViewHeight: CGFloat!
    fileprivate var notVisiblePartOfView: CGFloat!
    fileprivate let animationDuration: TimeInterval = 1
    fileprivate let constraintAfterTrackView: CGFloat = 10
    fileprivate var currentVisibleHeight: CGFloat!
    fileprivate var shouldBeTrackImageHeight: CGFloat {
        return shouldBeViewHeight - 80 //80 because all constraint and element height before trackimageview in total
    }
    fileprivate var multiplier: CGFloat {
        return (shouldBeTrackImageHeight - constraintAfterTrackView) / currentVisibleHeight
    }
    fileprivate var divider: CGFloat {
        return currentVisibleHeight / (shouldBeTrackImageHeight - constraintAfterTrackView)
    }
    fileprivate var tyConstant: CGFloat {
        return shouldBeTrackImageHeight - currentVisibleHeight - constraintAfterTrackView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func setUpPropertyForAnimation(allHeight: CGFloat, notVizibleHeight: CGFloat) {
        self.shouldBeViewHeight = allHeight
        self.notVisiblePartOfView = notVizibleHeight
    }

    func updateLabelWithText(_ text: String) {
        playerLabel.text = text
    }

    func changePlayButtonIcon(playNow: Bool) {
        playAndPauseButton.isSelected = playNow
    }

    //MARK: - fileprivate actions and functions
    fileprivate func commonInit(){
        Bundle.main.loadNibNamed("PlayerView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        trackImage.alpha = 0.0
    }

    @IBAction fileprivate func previousTrackButton(_ sender: Any) {
        delegat?.previousTrackDidTap(sender: self)
    }

    @IBAction fileprivate func backRewind(_ sender: Any) {
        delegat?.backRewindDidTap(sender: self)
    }

    @IBAction fileprivate func playAndPauseButton(_ sender: Any) {
        changePlayButtonIcon(playNow: !playAndPauseButton.isSelected)
        delegat?.playAndPauseDidTap(sender: self)
    }

    @IBAction fileprivate func forwardRewind(_ sender: Any) {
        delegat?.forwardRewindDidTap(sender: self)
    }

    @IBAction fileprivate func nextTrack(_ sender: Any) {
        delegat?.nextTrackDidTap(sender: self)
    }

    //MARK: - animation
    @IBAction fileprivate func panGestureRecognizerAction(_ sender: UIPanGestureRecognizer) {
        guard shouldBeViewHeight != nil && notVisiblePartOfView != nil else {return}
        switch sender.state {
        case .began:
            animator = self.createAnimation()

            animator.addCompletion { (postion) in
                self.trackImage.transform = CGAffineTransform.init(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
                self.redrawMyView()
            }
            animator.startAnimation()
            animator.pauseAnimation()
        case .changed:
            animator.fractionComplete = abs(sender.translation(in: self).y / notVisiblePartOfView)
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }

    fileprivate func createAnimation() -> UIViewPropertyAnimator {
        if currentVisibleHeight == nil {
            currentVisibleHeight = trackImage.frame.height
        }
        if self.transform == CGAffineTransform(translationX: 0, y: -notVisiblePartOfView) {
             return UIViewPropertyAnimator(duration: animationDuration, curve: .easeOut, animations: { [weak self] in
                guard let self = self else {return}
                self.transform = CGAffineTransform(translationX: 0, y: 0)
                self.trackImage.transform = CGAffineTransform.init(a: self.divider, b: 0.0, c: 0.0, d: self.divider, tx: 0.0, ty: -(self.tyConstant/2))
                self.trackImage.alpha = 0.0
            })
        } else {
            return UIViewPropertyAnimator(duration: animationDuration, curve: .easeOut, animations: { [weak self] in
                guard let self = self else {return}
                self.transform = CGAffineTransform(translationX: 0, y: -self.notVisiblePartOfView)
                self.trackImage.transform = CGAffineTransform.init(a: self.multiplier, b: 0.0, c: 0.0, d: self.multiplier, tx: 0.0, ty: self.tyConstant/2)
                self.trackImage.alpha = 1.0
            })
        }
    }

    fileprivate func redrawMyView() {
        let text = playerLabel.text!
        playerLabel.text = playerLabel.text! + " "
        playerLabel.text = text
    }
}
