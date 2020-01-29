//
//  AppDelegate.swift
//  IPhoneApp
//
//  Created by Sergey Pohrebnuak on 26.10.2019.
//  Copyright © 2019 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch  {
            print("Audio session failed")
        }

        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            _ = OverlayView(frame: CGRect(x: 0, y: 0, width: self.window!.frame.width, height: self.window!.frame.height), image: UIImage(named: "snowflake")!, showAlways: true)
        }

        return true
    }

}

