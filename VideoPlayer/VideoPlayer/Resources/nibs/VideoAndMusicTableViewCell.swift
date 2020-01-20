//
//  VideoAndMusicTableViewCell.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 14.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

class VideoAndMusicTableViewCell: UITableViewCell {


    @IBOutlet fileprivate weak var fileNameLabel: UILabel!
    @IBOutlet fileprivate weak var newImage: UIImageView!
    @IBOutlet fileprivate var fromLabelToSuperView: NSLayoutConstraint!
    @IBOutlet fileprivate var fromLabelToImage: NSLayoutConstraint!

    func setDataInCell(item: MusicOrVideoItem) {
        fileNameLabel.text = item.fileName
        newImage.isHidden = !item.isNew
        if item.isNew {
            fromLabelToSuperView.isActive = false
            fromLabelToImage.isActive = true
        } else {
            fromLabelToSuperView.isActive = true
            fromLabelToImage.isActive = false
        }
    }

}
