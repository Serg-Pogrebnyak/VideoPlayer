//
//  VideoViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import AVKit

struct MyVideoClip: Codable {
    let url: URL
    var position: Int
}

class VideoViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var playerController : AVPlayerViewController!
    
    fileprivate var myVideoClipArray = [MyVideoClip]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = UserDefaults.standard.value(forKey:"VideoList") as? Data {
            myVideoClipArray = try! PropertyListDecoder().decode(Array<MyVideoClip>.self, from: data)
            return
        }

        let videoArray = FileManager.default.getAFilesWithExtension(directory: .documentDirectory,
                                                                fileExtension: ".mp4") ?? [URL]()
        for (index, video) in videoArray.enumerated() {
            let myVideoClip = MyVideoClip(url: video, position: index)
            myVideoClipArray.append(myVideoClip)
        }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(myVideoClipArray), forKey:"VideoList")
    }

    @IBAction func didTapEditButton(_ sender: Any) {
        if tableView.isEditing {
            for (index, _) in myVideoClipArray.enumerated() {
                myVideoClipArray[index].position = index
            }
            UserDefaults.standard.set(try? PropertyListEncoder().encode(myVideoClipArray), forKey:"VideoList")
        }
        tableView.isEditing = !tableView.isEditing
    }
    
    @objc func didfinishPlaying(note : NSNotification)  {
        
        playerController.dismiss(animated: true, completion: nil)
        let alertView = UIAlertController(title: "Finished", message: "Video finished", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Okey", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
}

// MARK: - Extension Table view delegate
extension VideoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let player = AVPlayer(url: myVideoClipArray[indexPath.row].url)
        //let playerTimescale = player.currentItem?.asset.duration.timescale ?? 1
        //let time =  CMTime(seconds: 178.000000, preferredTimescale: playerTimescale)
        //player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        
        playerController = AVPlayerViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didfinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        playerController.player = player
        
        playerController.allowsPictureInPicturePlayback = true
        
        playerController.delegate = self
        
        
        self.present(playerController, animated: true, completion : nil)
    }
}

// MARK: - Extension Table view data source
extension VideoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myVideoClipArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        cell.textLabel?.text = myVideoClipArray[indexPath.row].url.lastPathComponent
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
        let myVideoClip = myVideoClipArray[sourceIndexPath.row]
        myVideoClipArray.remove(at: sourceIndexPath.row)
        myVideoClipArray.insert(myVideoClip, at: destinationIndexPath.row)
    }
}

extension VideoViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        
        let currentviewController = navigationController?.visibleViewController
        
        if currentviewController != playerViewController{
            
            currentviewController?.present(playerViewController, animated: true, completion: nil)
            
        }
        
    }
}
