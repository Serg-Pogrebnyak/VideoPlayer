//
//  VideoAndMusicTableViewCell.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 14.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

class VideoAndMusicTableViewCell: UITableViewCell {


    @IBOutlet fileprivate weak var downloadImage: UIImageView!
    @IBOutlet fileprivate weak var fileNameLabel: UILabel!
    @IBOutlet fileprivate weak var newImage: UIImageView!
    @IBOutlet fileprivate var fromLabelToSuperViewTraling: NSLayoutConstraint!
    @IBOutlet fileprivate var fromLabelToImageTraling: NSLayoutConstraint!
    @IBOutlet fileprivate var fromLabelToSuperViewLeading: NSLayoutConstraint!
    @IBOutlet fileprivate var fromLabelToImageLeading: NSLayoutConstraint!
    
    func setDataInCell(item: MusicOrVideoItem) {
        fileNameLabel.text = item.fileName
        newImage.isHidden = !item.isNew
        if item.isNew {
            fromLabelToSuperViewTraling.isActive = false
            fromLabelToImageTraling.isActive = true
        } else {
            fromLabelToSuperViewTraling.isActive = true
            fromLabelToImageTraling.isActive = false
        }
        
        if item.hasLocalFile() {
            downloadImage.isHidden = true
            fromLabelToSuperViewLeading.isActive = true
            fromLabelToImageLeading.isActive = false
        } else {
            downloadImage.isHidden = false
            fromLabelToSuperViewLeading.isActive = false
            fromLabelToImageLeading.isActive = true
        }
    }

}
