//
//  VideoViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import AVKit

class VideoViewController: UIViewController, MusicOrVideoArrayProtocol {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var playerController : AVPlayerViewController!
    internal var itemsArray = [MusicOrVideoItem]()
    fileprivate let videoUserDefaultsKey = "VideoList"
    fileprivate let videoExtension = ".mp4"
    fileprivate var customTableViewDelegate: CustomTableViewDelegate!
    fileprivate var customTableViewDataSource: CustomTableViewDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        //configure table view
        setupTableViewDelegateAndDataSource()
        let nib = UINib.init(nibName: "VideoAndMusicTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MusicCell")
        //UserDefaults.standard.removeObject(forKey: videoUserDefaultsKey)
        fetchAllTracksAndUpdateLibrary()
    }

    @IBAction func didTapEditButton(_ sender: Any) {
        if tableView.isEditing {
            saveChanges()
        }
        tableView.isEditing = !tableView.isEditing
    }
    
    @objc func didfinishPlaying(_ notification: NSNotification)  {
        let currentObject = notification.object as! AVPlayerItem
        let currentFileName = ((currentObject.asset) as? AVURLAsset)?.url.lastPathComponent
        let indexVideo = itemsArray.firstIndex {$0.fileName == currentFileName}!
        itemsArray[indexVideo].stoppedTime = nil
        if indexVideo+1 <= itemsArray.count {
            let url = FileManager.default.getURLS().appendingPathComponent(itemsArray[indexVideo+1].fileName, isDirectory: false)
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
        let indexVideo = itemsArray.firstIndex {$0.fileName == currentFileName}!
        itemsArray[indexVideo].stoppedTime = timeInSecond
        saveChanges()
    }

    func startPlay(atIndex index: Int, autoPlay: Bool = true) {
        let selectedVideo = itemsArray[index]
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
    
    //MARK: - Fileprivate func
    fileprivate func saveChanges() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(itemsArray), forKey: videoUserDefaultsKey)
    }

    fileprivate func fetchAllTracksAndUpdateLibrary() {
        var currentLibrary = [MusicOrVideoItem]()
        if let data = UserDefaults.standard.value(forKey:  videoUserDefaultsKey) as? Data {
            currentLibrary = try! PropertyListDecoder().decode(Array<MusicOrVideoItem>.self, from: data)
        }

        let musicURLArray = FileManager.default.getAllFilesWithExtension(directory: .documentDirectory,
                                                                         fileExtension: videoExtension) ?? [URL]()

        for URLofMusic in musicURLArray {
            var musicItem = MusicOrVideoItem.init(fileName: URLofMusic.lastPathComponent)
            if !currentLibrary.contains(musicItem) {
                musicItem.isNew = true
                itemsArray.append(musicItem)
            }
        }
        itemsArray = itemsArray + currentLibrary
        saveChanges()
        tableView.reloadData()
    }

    fileprivate func setupTableViewDelegateAndDataSource() {
        customTableViewDelegate = CustomTableViewDelegate(protocolObject: self)
        customTableViewDataSource = CustomTableViewDataSource(protocolObject: self)
        tableView.delegate = customTableViewDelegate
        tableView.dataSource = customTableViewDataSource
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
