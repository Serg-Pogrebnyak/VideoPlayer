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

    static var thumbBorderColor: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor.init(named: "thumbBorderColor")!
        } else {
            return .black
        }
    }

    static var thumbBackgroundColor: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor.init(named: "thumbBackgroundColor")!
        } else {
            return .white
        }
    }

    static var topGradientColor : UIColor {
        if #available(iOS 11.0, *) {
            return UIColor.init(named: "topGradient")!
        } else {
            return UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        }
    }

    static var bottomGradientColor : UIColor {
        if #available(iOS 11.0, *) {
            return UIColor.init(named: "bottomGradient")!
        } else {
            return UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        }
    }
}
