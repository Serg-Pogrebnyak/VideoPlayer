//
//  VideoViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import AVKit

class VideoViewController: AbstractMusicVideoViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var playerController : AVPlayerViewController!

    override func viewDidLoad() {
        setSomeParameter(tableView: tableView, itemExtension: ".mp4", view: EmptyVideoListView.loadFromNib())
        super.viewDidLoad()
        //UserDefaults.standard.removeObject(forKey: videoUserDefaultsKey)
    }
    
    @objc func didfinishPlaying(_ notification: NSNotification)  {
        guard let index = indexOfCurrentItem else {return}
        itemsArray[index].stoppedTime = nil
        if index+1 <= itemsArray.count-1 {
            indexOfCurrentItem = index+1
            unNewTrackAtIndex(index+1)
            let url = FileManager.default.documentDirectory.appendingPathComponent(itemsArray[index+1].displayFileName, isDirectory: false)
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
        let indexVideo = itemsArray.firstIndex {$0.displayFileName == currentFileName}!
        itemsArray[indexVideo].stoppedTime = timeInSecond as NSNumber
        saveChanges()
    }

    override func startPlay(atIndex index: Int, autoPlay: Bool = true) {
        indexOfCurrentItem = index
        unNewTrackAtIndex(index)
        let selectedVideo = itemsArray[index]
        var autoPlayMutuable = autoPlay

        let url = FileManager.default.documentDirectory.appendingPathComponent(selectedVideo.displayFileName, isDirectory: false)
        let player = AVPlayer(url: url)
        if let stoppedTime = selectedVideo.stoppedTime {
            let playerTimescale = player.currentItem?.asset.duration.timescale ?? 1
            let time =  CMTime(seconds: stoppedTime as! Double, preferredTimescale: playerTimescale)
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

extension VideoViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        
        let currentviewController = navigationController?.visibleViewController
        
        if currentviewController != playerViewController{
            
            currentviewController?.present(playerViewController, animated: true, completion: nil)
            
        }
    }
}
