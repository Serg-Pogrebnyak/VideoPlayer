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

    @IBOutlet fileprivate var backgroundView: UIView!
    @IBOutlet fileprivate weak var playerLabel: UILabel!
    @IBOutlet fileprivate weak var playAndPauseButton: UIButton!
    var delegat: PlayerViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit(){
        Bundle.main.loadNibNamed("PlayerView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func updateLabelWithText(_ text: String) {
        playerLabel.text = text
    }

    func changePlayButtonIcon(playNow: Bool) {
        playAndPauseButton.isSelected = playNow
    }

    //MARK: - fileprivate actions
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
}
