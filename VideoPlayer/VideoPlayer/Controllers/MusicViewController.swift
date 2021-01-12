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

class MusicViewController: UIViewController {
    
    private enum NavigationBarButtonStateEnum: String {
        case edit = "Edit"
        case cancel = "Cancel"
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var playerView: PlayerView!
    @IBOutlet private weak var fromBottomToTopPlayerViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playerViewHeightConstraint: NSLayoutConstraint!
    
    private var syncBarButtonItem: UIBarButtonItem!
    private var deleteBarButtonItem: UIBarButtonItem!
    private var editAndCancelBarButtonItem: UIBarButtonItem!
    lazy private var searchBar = UISearchBar(frame: CGRect.zero)
    
    private var navigationBarState = NavigationBarButtonStateEnum.edit
    private var itemsArray = [MusicOrVideoItem]()
    private var filterItemsArray = [MusicOrVideoItem]()
    private let rewind = CMTime(seconds: 15, preferredTimescale: 1)
    private var player = AVPlayer()
    private var nowPlayingInfo = [String: Any]()
    private var indexOfCurrentItem: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        //setup player view
        playerView.setUpPropertyForAnimation(allHeight: playerViewHeightConstraint.constant,
                                             notVizibleHeight: playerViewHeightConstraint.constant - fromBottomToTopPlayerViewConstraint.constant)
        playerView.delegat = self
        setupRemoteCommandCenter()
        checkNewLocaltemsAndUpdateLibrary()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.setGradientBackground()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.finishedAnimation()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true
        searchBar.delegate = self
        //add tap recognizer for search bar
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(titleWasTapped))
        self.navigationController?.navigationBar.addGestureRecognizer(recognizer)
        //create navigation bar buttons
        syncBarButtonItem = UIBarButtonItem(title: LocalizationManager.shared.getText("NavigationBar.syncButton.title"),
                                             style: .done,
                                             target: self,
                                             action: #selector(didTapSyncButton))
        syncBarButtonItem.image = UIImage.init(named: "sync")
        syncBarButtonItem.tintColor = UIColor.barColor
        self.navigationItem.leftBarButtonItem = syncBarButtonItem

        deleteBarButtonItem = UIBarButtonItem(title: LocalizationManager.shared.getText("NavigationBar.deleteButton.title"),
                                              style: .done,
                                              target: self,
                                              action: #selector(didTapDeleteButton))
        deleteBarButtonItem.tintColor = UIColor.red

        editAndCancelBarButtonItem = UIBarButtonItem(title: navigationBarState.rawValue,
                                                     style: .done,
                                                     target: self,
                                                     action: #selector(didTapEditAndCancelButton))
        editAndCancelBarButtonItem.image = UIImage.init(named: navigationBarState.rawValue)
        editAndCancelBarButtonItem.tintColor = UIColor.barColor
        self.navigationItem.rightBarButtonItem = editAndCancelBarButtonItem
    }
    
    //MARK: bar batton actions
    @objc private func didTapDeleteButton(_ sender: Any) {
        guard let array = tableView.indexPathsForSelectedRows else {return}
        let reversedArray = array.reversed()
        for indexPath in reversedArray {
            removeItem(atIndex: indexPath.row)
        }
        self.navigationItem.leftBarButtonItem = syncBarButtonItem
    }
    
    @objc private func didTapSyncButton(_ sender: Any) {
        checkNewLocaltemsAndUpdateLibrary()
    }
    
    @objc private func didTapEditAndCancelButton(_ sender: Any) {
        switch navigationBarState {
        case .cancel:
            self.view.endEditing(true)
            navigationBarState = .edit
            editAndCancelBarButtonItem.image = UIImage.init(named: navigationBarState.rawValue)
            editAndCancelBarButtonItem.title = navigationBarState.rawValue
            navigationItem.titleView = nil
        case .edit:
            self.navigationItem.leftBarButtonItem = syncBarButtonItem
            if tableView.isEditing {
                 saveChanges()
            }
            tableView.isEditing = !tableView.isEditing
        }
    }
    
    @objc private func titleWasTapped() {
        if navigationItem.titleView == nil {
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
            navigationBarState = .cancel
            editAndCancelBarButtonItem.image = UIImage.init(named: navigationBarState.rawValue)
            editAndCancelBarButtonItem.title = navigationBarState.rawValue
        }
    }

    //MARK: - overrided functions
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let currentItem = object as! AVPlayer
        print(currentItem.rate)
        if currentItem.rate > 0.0 {
            playerView.changePlayButtonIcon(playNow: true)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        } else {
            playerView.changePlayButtonIcon(playNow: false)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        }
        updateInformationOnLockScreen()
    }

    func startPlay(atIndex index: Int, autoPlay autoplay: Bool = true) {
        guard   !itemsArray.isEmpty,
                index >= 0,
                index < itemsArray.count
        else {return}

        indexOfCurrentItem = index
        unNewTrackAtIndex(index)
        let url = FileManager.default.getTempDirectory().appendingPathComponent(itemsArray[index].fileName, isDirectory: false)

        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlay), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        player = AVPlayer.init(playerItem: playerItem)
        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)

        if autoplay {
            player.play()
        }
        displayMusicInfo(fileUrl: url)
    }

    //MARK: setup remote command for display buttons on lock screen and in menu
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] (object) -> MPRemoteCommandHandlerStatus in
            guard let self = self else {return .commandFailed}
            let event = object as! MPChangePlaybackPositionCommandEvent
            self.rewindPlayerItemTo(CMTime.init(seconds: event.positionTime, preferredTimescale: 1))
            return .success
        }
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else {return .commandFailed}
            self.player.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else {return .commandFailed}
            self.player.pause()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let self = self else {return .commandFailed}
            if (self.indexOfCurrentItem ?? -1) + 1 <= self.itemsArray.count - 1 {
                self.startPlay(atIndex: self.indexOfCurrentItem!+1)
                return .success
            } else {
                return .noSuchContent
            }
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let self = self else {return .commandFailed}
            if (self.indexOfCurrentItem ?? +1) - 1 >= 0 {
                self.startPlay(atIndex: self.indexOfCurrentItem!-1)
                return .success
            } else {
                return .noSuchContent
            }
        }
    }
    
    private func checkNewLocaltemsAndUpdateLibrary() {
        itemsArray.removeAll()

        let musicOrVideoURLArray = FileManager.default.getAllFilesWithExtension(directory: .documentDirectory,
                                                                                fileExtension: ".mp3") ?? [URL]()
        var newObects = [MusicOrVideoItem]()
        
        for URLofItem in musicOrVideoURLArray {
            let musicItem = MusicOrVideoItem.init(fileName: URLofItem.lastPathComponent, filePathInDocumentFolder: URLofItem)
            musicItem.isNew = true
            newObects.append(musicItem)
        }
        CoreManager.shared.saveContext()
        
        itemsArray = CoreManager.shared.getElementsArray() ?? [MusicOrVideoItem]()
        filterItemsArray = itemsArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    //MARK: setup information about track on lock screen and in menu
    private func displayMusicInfo(fileUrl: URL) {
        nowPlayingInfo = [String: Any]()
        var imageForPlayerView: UIImage! = UIImage.init(named: "mp3")
        let asset = AVAsset(url: fileUrl) as AVAsset

        for metaDataItems in asset.commonMetadata {
            switch metaDataItems.commonKey!.rawValue {
            case "artist":
                guard let artist = metaDataItems.value as? String else {break}
                nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            case "albumName":
                guard let album = metaDataItems.value as? String else {break}
                nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
            case "artwork":
                guard   let imageData = metaDataItems.value as? Data,
                        let image = UIImage(data: imageData) else {break}
                imageForPlayerView = image
            default:
                continue
            }
        }

        nowPlayingInfo[MPMediaItemPropertyTitle] = itemsArray[indexOfCurrentItem!].fileName
        
        let artwork = MPMediaItemArtwork.init(boundsSize: imageForPlayerView.size, requestHandler: { (size) -> UIImage in
            return imageForPlayerView
        })

        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem!.asset.duration.seconds

        playerView.updateViewWith(text: nowPlayingInfo[MPMediaItemPropertyTitle] as! String, image: imageForPlayerView)

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func updateInformationOnLockScreen() {
        print(player.currentTime().stringSeconds)
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds as CFNumber
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    @objc private func playerDidFinishPlay() {
        guard   let index = indexOfCurrentItem,
                index + 1 <= itemsArray.count - 1
        else {return}

        startPlay(atIndex: index+1)
    }

    private func rewindPlayerItemTo(_ rewindTo: CMTime) {
        guard player.currentItem != nil else {return}
        player.seek(to: rewindTo) { [weak self] (flag) in
            guard let self = self, flag else {return}
            self.updateInformationOnLockScreen()
        }
    }
    
    private func unNewTrackAtIndex(_ index: Int) {
        guard itemsArray[index].isNew else {return}
        itemsArray[index].isNew = false
        saveChanges()
        tableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .middle)
    }
    
    private func selectedItems(count: Int) {
        if count > 0 {
            let buttonTitle = LocalizationManager.shared.getText("NavigationBar.deleteButton.title")
            deleteBarButtonItem.title = buttonTitle + "(\(count))"
            self.navigationItem.leftBarButtonItem = deleteBarButtonItem
        } else {
            self.navigationItem.leftBarButtonItem = syncBarButtonItem
        }
    }
    
    private func saveChanges() {
        CoreManager.shared.saveContext()
    }
    
    private func removeItem(atIndex index: Int) {
        do {
            let url = FileManager.default.getTempDirectory().appendingPathComponent(itemsArray[index].fileName, isDirectory: false)
            try FileManager.default.removeItem(at: url)
            let removedObject = itemsArray.remove(at: index)
            filterItemsArray.remove(at: index)
            tableView.reloadData()
            CoreManager.shared.coreManagerContext.delete(removedObject)
            saveChanges()
        } catch {
            showErrorAlertWithMessageByKey("Alert.Message.Can'tRemove")
        }
    }
}

extension MusicViewController: PlayerViewDelegate {
    func updateTimeLabel() -> (Double, Double)? {
        if player.currentItem != nil {
            return (player.currentTime().seconds, player.currentItem!.asset.duration.seconds)
        } else {
            return nil
        }
    }

    func previousTrackDidTap(sender: PlayerView) {
        guard let index = indexOfCurrentItem, index-1 <= self.itemsArray.count - 1 else {
            self.startPlay(atIndex: 0)
            return
        }
        self.startPlay(atIndex: index-1)
    }

    func forwardRewindDidTap(sender: PlayerView) {
        let rewindTo = player.currentTime() + rewind
        rewindPlayerItemTo(rewindTo)
    }

    func playAndPauseDidTap(sender: PlayerView) {
        guard player.currentItem != nil else {
            startPlay(atIndex: 0)
            return
        }
        if player.rate > 0.0 {
            player.pause()
        } else {
            player.play()
        }
    }

    func forcePlayOrPause(sender: PlayerView, shoudPlay: Bool, seekTo: Float?) {
        guard player.currentItem != nil else {return}

        if shoudPlay {
            rewindPlayerItemTo(CMTime.init(seconds: Double(seekTo!), preferredTimescale: 1))
            player.play()
        } else {
            player.pause()
        }
    }

    func backRewindDidTap(sender: PlayerView) {
        let rewindTo = player.currentTime() - rewind
        rewindPlayerItemTo(rewindTo)
    }

    func nextTrackDidTap(sender: PlayerView) {
        guard let index = indexOfCurrentItem, index+1 <= self.itemsArray.count - 1 else {
            self.startPlay(atIndex: 0)
            return
        }
        self.startPlay(atIndex: index+1)
    }
}

//MARK: - UISearchBarDelegate
extension MusicViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedString = searchText
        self.itemsArray.removeAll()

        if trimmedString.isEmpty {
            self.itemsArray = self.filterItemsArray
        }else{
            self.itemsArray = self.filterItemsArray.filter({ (musicItem) -> Bool in
                return musicItem.fileName.contains(trimmedString)
            })
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}

extension MusicViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let countOfSelected = tableView.indexPathsForSelectedRows?.count ?? 0
            selectedItems(count: countOfSelected)
        } else {
            let item = itemsArray[indexPath.row]
            if item.hasLocalFile() {
                tableView.deselectRow(at: indexPath, animated: true)
                startPlay(atIndex: indexPath.row, autoPlay: true)
            } else {
                    tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let countOfSelected = tableView.indexPathsForSelectedRows?.count ?? 0
            selectedItems(count: countOfSelected)
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .destructive, title: "") { [weak self] (action, indexPath) in
            self?.removeItem(atIndex: indexPath.row)
        }
        deleteAction.backgroundColor = UIColor(patternImage: UIImage(named: "trash")!)

        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
}

extension MusicViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemsArray.isEmpty {
            let emptyView = EmptyMusicListView.loadFromNib()
            tableView.backgroundView = emptyView
            emptyView.startAnimation()
        } else {
            tableView.backgroundView = nil
        }
        return itemsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! VideoAndMusicTableViewCell
        cell.setDataInCell(item: itemsArray[indexPath.row])
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
        let movedMusicItem = itemsArray[sourceIndexPath.row]
        itemsArray.remove(at: sourceIndexPath.row)
        movedMusicItem.isNew = false
        itemsArray.insert(movedMusicItem, at: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let path = FileManager.default.getTempDirectory().appendingPathComponent(itemsArray[indexPath.row].fileName, isDirectory: false)
            do {
                try FileManager.default.removeItem(at: path)
                itemsArray.remove(at: indexPath.row)
                tableView.reloadData()
            } catch {
                showErrorAlertWithMessageByKey("Alert.Message.FileNotFound")
            }
        }
    }
}
