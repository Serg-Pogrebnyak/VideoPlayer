//
//  ButtonFabric.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 03.02.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

struct ButtonFabric {
    //MARK: Constants
    private static let cornerRadius: CGFloat = 5
    private static let boldFontSize: CGFloat = 20
    
    //MARK: Functions
    static func makeBoldColorButton(_ button: UIButton) {
        button.backgroundColor = .firstGeneralColor
        button.tintColor = .secondGeneralColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: boldFontSize)
        button.layer.cornerRadius = cornerRadius
    }
}
