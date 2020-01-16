//
//  MusicViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

class MusicViewController: UIViewController, MusicOrVideoArrayProtocol {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    internal var itemsArray = [MusicOrVideoItem]()
    fileprivate var player: AVAudioPlayer?
    fileprivate var indexOfCurrentItem: Int?
    fileprivate let musicUserDefaultsKey = "MusicList"
    fileprivate let musicExtension = ".mp3"
    fileprivate var customTableViewDelegate: CustomTableViewDelegate!
    fileprivate var customTableViewDataSource: CustomTableViewDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        //configure table view
        setupTableViewDelegateAndDataSource()
        let nib = UINib.init(nibName: "VideoAndMusicTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MusicCell")
        //UserDefaults.standard.removeObject(forKey: musicUserDefaultsKey)
        fetchAllTracksAndUpdateLibrary()
        setupRemoteCommandCenter()
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        if tableView.isEditing {
             saveChanges()
         }
        tableView.isEditing = !tableView.isEditing
    }

    func startPlay(atIndex index: Int, autoPlay autoplay: Bool) {
        indexOfCurrentItem = index
        let url = FileManager.default.getURLS().appendingPathComponent(itemsArray[index].fileName, isDirectory: false)
        do {

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }

            player.play()

            displayMusicInfo(fileUrl: url)
        } catch let error {
            print(error.localizedDescription)//TODO
        }
    }
    
    //MARK: - Fileprivate func
    fileprivate func saveChanges() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(itemsArray), forKey: musicUserDefaultsKey)
    }

    fileprivate func fetchAllTracksAndUpdateLibrary() {
        var currentLibrary = [MusicOrVideoItem]()
        if let data = UserDefaults.standard.value(forKey: musicUserDefaultsKey) as? Data {
            currentLibrary = try! PropertyListDecoder().decode(Array<MusicOrVideoItem>.self, from: data)
        }

        let musicURLArray = FileManager.default.getAllFilesWithExtension(directory: .documentDirectory,
                                                                         fileExtension: musicExtension) ?? [URL]()

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

    //MARK: setup remote command for display buttons on lock screen and in menu
    fileprivate func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            self.player?.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            self.player?.pause()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget {event in
            if (self.indexOfCurrentItem ?? -1) + 1 > self.itemsArray.count - 1 {
                return .noSuchContent
            } else {
                self.startPlay(atIndex: self.indexOfCurrentItem!+1, autoPlay: false)
                return .success
            }
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget {event in
            if (self.indexOfCurrentItem ?? +1) - 1 < 0 {
                return .noSuchContent
            } else {
                self.startPlay(atIndex: self.indexOfCurrentItem!-1, autoPlay: false)
                return .success
            }
        }
    }

    //MARK: setup information about track on lock screen and in menu
    fileprivate func displayMusicInfo(fileUrl: URL) {
        var nowPlayingInfo = [String: Any]()
        let asset = AVAsset(url: fileUrl) as AVAsset

        for metaDataItems in asset.commonMetadata {
            switch metaDataItems.commonKey!.rawValue {
            case "title":
                guard let title = metaDataItems.value as? String else {break}
                nowPlayingInfo[MPMediaItemPropertyTitle] = title
            case "artist":
                guard let artist = metaDataItems.value as? String else {break}
                nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            case "albumName":
                guard let album = metaDataItems.value as? String else {break}
                nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
            case "artwork":
                guard let imageData = metaDataItems.value as? Data else {break}
                let image = UIImage(data: imageData)!
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
            default:
                continue
            }
        }

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.duration

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
