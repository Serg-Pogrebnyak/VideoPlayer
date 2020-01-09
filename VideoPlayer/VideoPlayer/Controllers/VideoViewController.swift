//
//  VideoViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var videoArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videos = FileManager.default.getAFilesWithExtension(directory: .documentDirectory,
                                                                      fileExtension: ".mp4") else {return}
        
        for video in videos {
            videoArray.append(video.lastPathComponent)
        }
    }

}

// MARK: - Extension Table view delegate
extension VideoViewController: UITableViewDelegate {
    
}

// MARK: - Extension Table view data source
extension VideoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        cell.textLabel?.text = videoArray[indexPath.row]
        return cell
    }
}
