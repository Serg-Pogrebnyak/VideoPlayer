//
//  MusicViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import Foundation

struct MusicItem: Codable {
    let fileName: String
    let position: Int
}

class MusicViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var musicArray = [MusicItem]()
    fileprivate let musicUserDefaultsKey = "MusicList"
    fileprivate let musicExtension = ".mp3"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = UserDefaults.standard.value(forKey: musicUserDefaultsKey) as? Data {
            musicArray = try! PropertyListDecoder().decode(Array<MusicItem>.self, from: data)
            return
        }

        let musicURLArray = FileManager.default.getAFilesWithExtension(directory: .documentDirectory,
                                                                    fileExtension: musicExtension) ?? [URL]()
        
        for (index, URLofMusic) in musicURLArray.enumerated() {
            let musicItem = MusicItem(fileName: URLofMusic.lastPathComponent, position: index)
            musicArray.append(musicItem)
        }
        saveChanges()
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
    }
    
    //MARK: - Fileprivate func
    fileprivate func saveChanges() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(musicArray), forKey: musicUserDefaultsKey)
    }
}

// MARK: - Extension Table view delegate
extension MusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //startPlayVideoAtIndex(indexPath.row)
    }
}

// MARK: - Extension Table view data source
extension MusicViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        cell.textLabel?.text = musicArray[indexPath.row].fileName
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
        let movedMusicItem = musicArray[sourceIndexPath.row]
        musicArray.remove(at: sourceIndexPath.row)
        musicArray.insert(movedMusicItem, at: destinationIndexPath.row)
    }
}
