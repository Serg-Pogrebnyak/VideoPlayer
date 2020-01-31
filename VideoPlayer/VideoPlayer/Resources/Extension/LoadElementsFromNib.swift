//
//  LoadElementsFromNib.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 31.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation

protocol AbstractNibView: class {
    static func loadFromNib() -> Self
}

extension AbstractNibView {
    static func loadFromNib() -> Self {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)!.first as! Self
    }
}
