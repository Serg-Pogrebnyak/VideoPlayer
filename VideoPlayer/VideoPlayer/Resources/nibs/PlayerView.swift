//
//  PlayerView.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 20.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

protocol PlayerViewDelegate: class {
    func previousTrackDidTap(sender: PlayerView)
    func backRewindDidTap(sender: PlayerView)
    func playAndPauseDidTap(sender: PlayerView)
    func forcePlayOrPause(sender: PlayerView, shoudPlay: Bool, seekTo: Float?)
    func forwardRewindDidTap(sender: PlayerView)
    func nextTrackDidTap(sender: PlayerView)
    func updateTimeLabel() -> (Double, Double)?
}

extension PlayerViewDelegate {
    func backRewindDidTap(sender: PlayerView) {}
    func forwardRewindDidTap(sender: PlayerView) {}
}

class PlayerView: UIView {

    weak var delegat: PlayerViewDelegate?

    @IBOutlet fileprivate var backgroundView: UIView!
    @IBOutlet fileprivate weak var playerLabel: UILabel!
    @IBOutlet fileprivate weak var playAndPauseButton: UIButton!
    @IBOutlet fileprivate weak var trackImage: UIImageView!
    @IBOutlet fileprivate weak var currentTimeLabel: UILabel!
    @IBOutlet fileprivate weak var remainingTimeLabel: UILabel!
    @IBOutlet fileprivate weak var progressSlider: UISlider!

    fileprivate var gradientLayer: CAGradientLayer!
    fileprivate var timerForUpdateTiemLabel: Timer?
    fileprivate var pausedTimer = false
    //animation property
    @available(iOS 10.0, *)
    lazy fileprivate var animator = UIViewPropertyAnimator()
    fileprivate var shouldBeViewHeight: CGFloat!
    fileprivate var notVisiblePartOfView: CGFloat!
    fileprivate let animationDuration: TimeInterval = 1
    fileprivate let constraintAfterTrackView: CGFloat = 10
    fileprivate var currentVisibleHeight: CGFloat!
    fileprivate var shouldBeTrackImageHeight: CGFloat {
        return shouldBeViewHeight - 115 //115 because all constraint and element height before trackimageview in total
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

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = self.bounds
        gradientLayer?.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        if #available(iOS 10.0, *) {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }

    func finishedAnimation() {
        if #available(iOS 10.0, *) {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }

    func setGradientBackground() {
        guard gradientLayer == nil else {return}
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.topGradientColor.cgColor,
                                UIColor.bottomGradientColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.backgroundView.frame
        gradientLayer.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        gradientLayer.masksToBounds = true
        backgroundView.layer.insertSublayer(gradientLayer, at:0)
    }

    func updateViewWith(text: String, image: UIImage) {
        playerLabel.text = text
        trackImage.image = image
        progressSlider.isEnabled = true
    }

    func changePlayButtonIcon(playNow: Bool) {
        playAndPauseButton.isSelected = playNow
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - fileprivate actions and functions
    fileprivate func commonInit(){
        Bundle.main.loadNibNamed("PlayerView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        trackImage.alpha = 0.0
        progressSlider.setCustomThumb()
        timerForUpdateTiemLabel = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(getNewTimeFromDelegate), userInfo: nil, repeats: true)
        self.progressSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: UIControl.Event.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
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
    @available(iOS 10.0, *)
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
            if self.transform == CGAffineTransform(translationX: 0, y: -notVisiblePartOfView) {
                guard sender.translation(in: self).y < 0 else {return}
                animator.fractionComplete = abs(sender.translation(in: self).y / notVisiblePartOfView)
            } else {
                guard sender.translation(in: self).y > 0 else {return}
                animator.fractionComplete = sender.translation(in: self).y / notVisiblePartOfView
            }
        case .ended:
            if self.transform == CGAffineTransform(translationX: 0, y: -notVisiblePartOfView) {
                guard sender.translation(in: self).y < 0 else {
                    animator.fractionComplete = 0.0
                    animator.stopAnimation(true)
                    animator.finishAnimation(at: .current)
                    self.transform = CGAffineTransform(translationX: 0, y: 0)
                    return
                }
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            } else {
                guard sender.translation(in: self).y > 0 else {
                    animator.fractionComplete = 0.0
                    animator.stopAnimation(true)
                    animator.finishAnimation(at: .current)
                    self.transform = CGAffineTransform(translationX: 0, y: -self.notVisiblePartOfView)
                    return
                }
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        default:
            break
        }
    }

    @available(iOS 10.0, *)
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

    fileprivate func redrawMyView() {//greates kostul but work
        let text = playerLabel.text!
        playerLabel.text = playerLabel.text! + " "
        playerLabel.text = text
    }

    @objc fileprivate func getNewTimeFromDelegate() {
        guard let object = delegat?.updateTimeLabel(), !pausedTimer else {return}
        let duration = roundl(object.1)
        currentTimeLabel.text = object.0.stringFromTimeInterval()
        remainingTimeLabel.text = (duration-object.0).stringFromTimeInterval()
        progressSlider.maximumValue = Float(duration)
        progressSlider.value = Float(object.0)
    }

    @objc fileprivate func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                self.delegat?.forcePlayOrPause(sender: self, shoudPlay: false, seekTo: nil)
                pausedTimer = true
            case .moved:
                currentTimeLabel.text = Double(progressSlider.value).stringFromTimeInterval()
                remainingTimeLabel.text = Double(progressSlider.maximumValue - progressSlider.value).stringFromTimeInterval()
            case .ended:
                self.delegat?.forcePlayOrPause(sender: self, shoudPlay: true, seekTo: slider.value)
                pausedTimer = false
            default:
                break
            }
        }
    }

    @objc fileprivate func willEnterForeground() {
        DispatchQueue.main.async() {
            self.progressSlider.setCustomThumb()
            self.gradientLayer.colors = [UIColor.topGradientColor.cgColor,
                                         UIColor.bottomGradientColor.cgColor]
        }
    }
}
