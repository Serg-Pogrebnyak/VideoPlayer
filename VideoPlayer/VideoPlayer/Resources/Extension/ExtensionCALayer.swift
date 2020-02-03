//
//  ExtensionCALayer.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 29.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

extension CALayer {
    /**
     Add like snow animation layer
     - Parameters:
        - image: image which will animate, size shouldbe  48*48 - it's perfect size for animation
        - shoudRotate: rotation around image axis, default value - false
        - rRange: change red image component, default value - 0.0
        - gRange: change green image component, default value - 0.0
        - bRange: change blue image component, default value - 0.0
     - Author: Serg P
     - Version: 0.1
     - Date: 29.01.2020
    */
    func addSnowEffectLayer(image: UIImage, shoudRotate: Bool = false, rRange: Float = 0.0, gRange: Float = 0.0, bRange: Float = 0.0) {
        let emitterLayer = CAEmitterLayer()

        emitterLayer.emitterPosition = CGPoint(x: self.frame.width/2, y: -500)
        emitterLayer.beginTime = CACurrentMediaTime()
        let cell = CAEmitterCell()

        cell.birthRate = 5//count of element per second
        cell.lifetime = 60
        cell.velocity = 50//start speed
        cell.velocityRange = 100//speed range
        cell.scale = 0.75
        cell.scaleRange = 0.5 //if scale range >> scale image can flip over (not rotates)
        cell.yAcceleration = 1.5
        cell.redRange = rRange
        cell.greenRange = gRange
        cell.blueRange = bRange
        if shoudRotate {
            cell.spin = CGFloat.pi/4.0
            cell.spinRange = CGFloat.pi/8.0
        }

        cell.emissionRange = CGFloat.pi//180 degrees in radian
        cell.contents = image.cgImage

        emitterLayer.emitterCells = [cell]
        self.addSublayer(emitterLayer)
    }
}

extension CAGradientLayer {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.mask = mask
    }
}
