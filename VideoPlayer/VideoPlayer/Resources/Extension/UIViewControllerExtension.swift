//
//  UIViewControllerExtension.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 15.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorAlertWithMessageByKey(_ key: String) {
        let title = LocalizationManager.shared.getText("Alert.Error.Title")
        let buttonOK = LocalizationManager.shared.getText("Alert.Button.OK")
        let message = LocalizationManager.shared.getText(key)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonOK, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
