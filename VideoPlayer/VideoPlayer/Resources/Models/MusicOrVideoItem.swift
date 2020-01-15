//
//  MusicOrVideoItem.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 14.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation

protocol MusicOrVideoArrayProtocol: class {
    var itemsArray: [MusicOrVideoItem] {get set}
    func startPlay(atIndex index: Int)
}

class MusicOrVideoItem: Codable, Equatable {
    let fileName: String
    var isNew: Bool

    init(filename: String, isNew: Bool = false) {
        self.fileName = filename
        self.isNew = isNew
    }

    static func == (lfs:MusicOrVideoItem, rfs:MusicOrVideoItem) -> Bool {
        return lfs.fileName == rfs.fileName
    }
}
