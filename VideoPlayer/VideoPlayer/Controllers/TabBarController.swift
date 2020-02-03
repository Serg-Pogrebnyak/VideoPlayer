//
//  TabBarController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = UIColor.barColor
    }

}
