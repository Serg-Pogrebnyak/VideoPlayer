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
    func startPlay(atIndex index: Int, autoPlay: Bool)
    func removeItem(atIndex index: Int)
}

struct MusicOrVideoItem: Codable, Equatable {
    let fileName: String
    var isNew: Bool
    var stoppedTime: Double?

    init(fileName: String, isNew: Bool = false, stoppedTime: Double? = nil) {
        self.fileName = fileName
        self.isNew = isNew
        self.stoppedTime = stoppedTime
    }

    static func == (lfs:MusicOrVideoItem, rfs:MusicOrVideoItem) -> Bool {
        return lfs.fileName == rfs.fileName
    }
}
