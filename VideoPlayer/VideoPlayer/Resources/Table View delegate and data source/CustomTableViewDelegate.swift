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
        if tableView.isEditing {
            let countOfSelected = tableView.indexPathsForSelectedRows?.count ?? 0
            musicOrVideoArrayProtocol.selectedItems(count: countOfSelected)
        } else {
            let item = musicOrVideoArrayProtocol.itemsArray[indexPath.row]
            if item.hasLocalFile() {
                tableView.deselectRow(at: indexPath, animated: true)
                musicOrVideoArrayProtocol.startPlay(atIndex: indexPath.row, autoPlay: true)
            } else {
                    tableView.deselectRow(at: indexPath, animated: true)
//                    CloudCoreData.loadFile(recordName: item.remoteId!, fileName: item.fileName, completion: {
//                        DispatchQueue.main.async {
//                            tableView.reloadData()
//                        }
//                    })
            }
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let countOfSelected = tableView.indexPathsForSelectedRows?.count ?? 0
            musicOrVideoArrayProtocol.selectedItems(count: countOfSelected)
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .destructive, title: "") { [weak self] (action, indexPath) in
            self?.musicOrVideoArrayProtocol.removeItem(atIndex: indexPath.row)
        }
        deleteAction.backgroundColor = UIColor(patternImage: UIImage(named: "trash")!)

        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
}
