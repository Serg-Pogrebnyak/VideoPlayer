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
        musicOrVideoArrayProtocol.startPlay(atIndex: indexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let path = FileManager.default.getURLS().appendingPathComponent(musicOrVideoArrayProtocol.musicArray[indexPath.row].fileName, isDirectory: false)
            do {
                try FileManager.default.removeItem(at: path)
                musicOrVideoArrayProtocol.musicArray.remove(at: indexPath.row)
                tableView.reloadData()
            } catch {
                print("error")//TODO handle error
            }
        }
    }
}
