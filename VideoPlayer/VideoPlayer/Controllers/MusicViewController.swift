//
//  MusicViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import Foundation

class MusicViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var musicArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let musics = FileManager.default.getAFilesWithExtension(directory: .documentDirectory,
                                                                      fileExtension: ".mp3") else {return}
        
        for music in musics {
            musicArray.append(music.lastPathComponent)
        }
    }

}

// MARK: - Extension Table view delegate
extension MusicViewController: UITableViewDelegate {
    
}

// MARK: - Extension Table view data source
extension MusicViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        cell.textLabel?.text = musicArray[indexPath.row]
        return cell
    }
}
