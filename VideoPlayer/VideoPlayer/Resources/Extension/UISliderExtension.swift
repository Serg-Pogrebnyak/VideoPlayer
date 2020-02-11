//
//  UISliderExtension.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 06.02.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

extension UISlider {
    func setCustomThumb(radius: CGFloat = 20.0) {
        self.tintColor = .thumbBackgroundColor
        let thumb = UIView()
        thumb.backgroundColor = .thumbBackgroundColor
        thumb.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumb.layer.cornerRadius = radius / 2

        let image: UIImage!
        if #available(iOS 10.0, *) {
            thumb.layer.borderWidth = 0.4
            thumb.layer.borderColor = UIColor.thumbBorderColor.cgColor
            let renderer = UIGraphicsImageRenderer(bounds: thumb.bounds)
            image = renderer.image { rendererContext in
                thumb.layer.render(in: rendererContext.cgContext)
            }
        } else {
            var layer: CALayer = CALayer()
            layer = thumb.layer
            UIGraphicsBeginImageContext(thumb.bounds.size)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        self.setThumbImage(image, for: .normal)
    }
}
