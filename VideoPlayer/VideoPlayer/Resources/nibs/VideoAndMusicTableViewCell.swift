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

    func setDataInCell(item: MusicOrVideoItem) {
        fileNameLabel.text = item.fileName
        newImage.isHidden = !item.isNew
    }

}
