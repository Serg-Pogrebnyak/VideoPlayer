//
//  MusicRouter.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 03.02.2021.
//  Copyright © 2021 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

protocol MusicRouterInput {
    func presentSyncMusicViewController()
}

final class MusicRouter: MusicRouterInput {

    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    //MARK: - Music Router Input
    func presentSyncMusicViewController() {
        print("😝 Sync VC was presented")
    }
}
