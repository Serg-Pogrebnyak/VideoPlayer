//
//  LocalizationManager.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 15.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation

class LocalizationManager: NSObject  {
    static let shared = LocalizationManager()

    func getText(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "ApplicationText", bundle: .main, value: "", comment: "")
    }

}
