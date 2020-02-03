//
//  UIColorExtension.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 03.02.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

extension UIColor {
    static var barColor: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor.init(named: "barColor")!
        } else {
            return .black
        }
    }
}
