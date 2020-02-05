//
//  CMTimeExtension.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 05.02.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import MediaPlayer

extension CMTime {
    var seconds: Float64 {
        return CMTimeGetSeconds(self)
    }

    var stringSeconds: String {
        return String(Double(self.seconds))
    }
}
