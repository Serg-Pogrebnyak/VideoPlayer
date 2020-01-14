//
//  CustomTableViewDataSource.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 14.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

class CustomTableViewDataSource: NSObject, UITableViewDataSource {

    fileprivate weak var musicOrVideoArrayProtocol: MusicOrVideoArrayProtocol!

    init (protocolObject: MusicOrVideoArrayProtocol) {
        self.musicOrVideoArrayProtocol = protocolObject
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicOrVideoArrayProtocol.musicArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! VideoAndMusicTableViewCell
        cell.setDataInCell(item: musicOrVideoArrayProtocol.musicArray[indexPath.row])
        return cell
    }

    // MARK: - Table view cell moving
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedMusicItem = musicOrVideoArrayProtocol.musicArray[sourceIndexPath.row]
        musicOrVideoArrayProtocol.musicArray.remove(at: sourceIndexPath.row)
        movedMusicItem.isNew = false
        musicOrVideoArrayProtocol.musicArray.insert(movedMusicItem, at: destinationIndexPath.row)
        tableView.reloadData()
    }
}
