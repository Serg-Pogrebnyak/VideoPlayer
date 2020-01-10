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
    var fileName: String
    var position: Int
    var stoppedTime: Double?
}

class VideoViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var playerController : AVPlayerViewController!
    fileprivate var myVideoClipArray = [MyVideoClip]()
    fileprivate let videoUserDefaultsKey = "VideoList"
    fileprivate let videoExtension = ".mp4"

    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = UserDefaults.standard.value(forKey: videoUserDefaultsKey) as? Data {
            myVideoClipArray = try! PropertyListDecoder().decode(Array<MyVideoClip>.self, from: data)
            return
        }

        let videoArray = FileManager.default.getAFilesWithExtension(directory: .documentDirectory,
                                                                    fileExtension: videoExtension) ?? [URL]()
        
        for (index, URLofVideo) in videoArray.enumerated() {
            let myVideoClip = MyVideoClip(fileName: URLofVideo.lastPathComponent, position: index)
            myVideoClipArray.append(myVideoClip)
        }
        saveChanges()
    }

    @IBAction func didTapEditButton(_ sender: Any) {
        if tableView.isEditing {
            for (index, _) in myVideoClipArray.enumerated() {
                myVideoClipArray[index].position = index
            }
            UserDefaults.standard.set(try? PropertyListEncoder().encode(myVideoClipArray), forKey: videoUserDefaultsKey)
        }
        tableView.isEditing = !tableView.isEditing
    }
    
    @objc func didfinishPlaying(_ notification: NSNotification)  {
        let currentObject = notification.object as! AVPlayerItem
        let currentFileName = ((currentObject.asset) as? AVURLAsset)?.url.lastPathComponent
        let indexVideo = myVideoClipArray.firstIndex {$0.fileName == currentFileName}!
        myVideoClipArray[indexVideo].stoppedTime = nil
        if indexVideo+1 <= myVideoClipArray.count {
            let url = FileManager.default.getURLS().appendingPathComponent(myVideoClipArray[indexVideo+1].fileName, isDirectory: false)
            let player = AVPlayer(url: url)
            playerController.player = player
            player.play()
        } else {
            playerController.dismiss(animated: true, completion: nil)
        }
        saveChanges()
    }
    
    @objc func playerCloseBeforeEndVideo(_ notification : NSNotification)  {
        let currentObject = notification.object as! AVPlayerItem
        let time = currentObject.currentTime()
        let timeInSecond = Double(time.value)/Double(time.timescale)
        let currentFileName = ((currentObject.asset) as? AVURLAsset)?.url.lastPathComponent
        let indexVideo = myVideoClipArray.firstIndex {$0.fileName == currentFileName}!
        myVideoClipArray[indexVideo].stoppedTime = timeInSecond
        saveChanges()
    }
    
    //MARK: - Fileprivate func
    fileprivate func saveChanges() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(myVideoClipArray), forKey: videoUserDefaultsKey)
    }
    
    fileprivate func startPlayVideoAtIndex(_ index: Int, autoPlay: Bool = true) {
        let selectedVideo = myVideoClipArray[index]
        var autoPlayMutuable = autoPlay
        
        let url = FileManager.default.getURLS().appendingPathComponent(selectedVideo.fileName, isDirectory: false)
        let player = AVPlayer(url: url)
        if let stoppedTime = selectedVideo.stoppedTime {
            let playerTimescale = player.currentItem?.asset.duration.timescale ?? 1
            let time =  CMTime(seconds: stoppedTime, preferredTimescale: playerTimescale)
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            autoPlayMutuable = false
        }
        
        playerController = AVPlayerViewController()
        NotificationCenter.default.addObserver(self, selector: #selector(didfinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerCloseBeforeEndVideo), name: NSNotification.Name.AVPlayerItemTimeJumped, object: player.currentItem)
        playerController.player = player
        playerController.allowsPictureInPicturePlayback = true
        playerController.delegate = self
        
        self.present(playerController, animated: true) {
            if autoPlayMutuable {
                player.play()
            }
        }
    }
}

// MARK: - Extension Table view delegate
extension VideoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        startPlayVideoAtIndex(indexPath.row)
    }
}

// MARK: - Extension Table view data source
extension VideoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myVideoClipArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        cell.textLabel?.text = myVideoClipArray[indexPath.row].fileName
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
