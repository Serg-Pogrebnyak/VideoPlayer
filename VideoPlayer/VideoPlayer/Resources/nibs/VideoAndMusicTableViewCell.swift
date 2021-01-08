//
//  VideoAndMusicTableViewCell.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 14.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

class VideoAndMusicTableViewCell: UITableViewCell {


    @IBOutlet private weak var downloadImage: UIImageView!
    @IBOutlet private weak var fileNameLabel: UILabel!
    @IBOutlet private weak var newImage: UIImageView!
    @IBOutlet private var fromLabelToSuperViewTraling: NSLayoutConstraint!
    @IBOutlet private var fromLabelToImageTraling: NSLayoutConstraint!
    @IBOutlet private var fromLabelToSuperViewLeading: NSLayoutConstraint!
    @IBOutlet private var fromLabelToImageLeading: NSLayoutConstraint!
    
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
