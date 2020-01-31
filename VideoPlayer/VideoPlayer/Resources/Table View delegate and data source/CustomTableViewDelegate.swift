//
//  TableViewDelegate.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 14.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

class CustomTableViewDelegate: NSObject, UITableViewDelegate {
    
    fileprivate weak var musicOrVideoArrayProtocol: MusicOrVideoArrayProtocol!

    init (protocolObject: MusicOrVideoArrayProtocol) {
        self.musicOrVideoArrayProtocol = protocolObject
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        musicOrVideoArrayProtocol.startPlay(atIndex: indexPath.row, autoPlay: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .destructive, title: "") { (action, indexPath) in
            print("work method for ios 9")
        }
        deleteAction.backgroundColor = UIColor(patternImage: UIImage(named: "trash")!)

        return [deleteAction]
    }
}
