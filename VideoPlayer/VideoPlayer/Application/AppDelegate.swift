//
//  AppDelegate.swift
//  IPhoneApp
//
//  Created by Sergey Pohrebnuak on 26.10.2019.
//  Copyright © 2019 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            guard let imageForOverlayView = UIImage(named: "snowflake") else {return}
            let rect = CGRect(x: 0,
                              y: 0,
                              width: self.window!.frame.width,
                              height: self.window!.frame.height)
            _ = OverlayView(frame: rect,
                            image: imageForOverlayView,
                            showAlways: true)
        }

        return true
    }

}

