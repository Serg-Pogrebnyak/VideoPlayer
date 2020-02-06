//
//  TimeIntervalExtension.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 06.02.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation

extension TimeInterval{
    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        if hours > 0 {
            return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        } else {
            return String(minutes)+":"+String(format: "%0.2d",seconds)
        }
    }
}
