//
//  MusicViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 13.01.2021.
//  Copyright (c) 2021 Sergey Pohrebnuak. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

protocol MusicDisplayLogic: class {
    func displayMusicItemsArray(viewModel: Music.FetchLocalItems.ViewModel)
    func unnewMusicItem(viewModel: Music.StartPlayOrDownload.ViewModel)
    func updatePlaynigSongInfo(viewModel: Music.UpdatePlayingSongInfo.ViewModel)
}

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
    private var musicItemsArray = [Music.MusicDisplayData]()
    private var itemsArray = [MusicOrVideoItem]()
    private var itemsSet = Set<MusicOrVideoItem>()
    private let rewind = CMTime(seconds: 15, preferredTimescale: 1)
    private var player = AVPlayer()
    private var nowPlayingInfo = [String: Any]()
    private var indexOfCurrentItem: Int?
    
    private var interactor: MusicBusinessLogic?
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCleanCycle()
        playerView.delegat = self
        setupRemoteCommandCenter()
        //FileManager.default.removeAllFromTempDirectory()
        fetchLocalItems()
        setupUI()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedToForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.setGradientBackground()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.finishedAnimation()
    }
    
    @objc private func appMovedToForeground() {
        let request = Music.UpdatePlayingSongInfo.Request()
        interactor?.updatePlayingSongInfo(request: request)
    }
    
    // MARK: Setup
    private func setupCleanCycle() {
        let viewController = self
        let interactor = MusicInteractor()
        let presenter = MusicPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    private func setupUI() {
        let nib = UINib.init(nibName: "VideoAndMusicTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MusicCell")
        
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
        
        //setup player view
        playerView.setUpPropertyForAnimation(allHeight: playerViewHeightConstraint.constant,
                                             notVizibleHeight: playerViewHeightConstraint.constant - fromBottomToTopPlayerViewConstraint.constant)
    }
    
    //MARK: Do some business logic
    private func fetchLocalItems() {
        let request = Music.FetchLocalItems.Request()
        interactor?.fetchLocalItems(request: request)
    }
    
    //MARK: bar batton actions
    @objc private func didTapDeleteButton(_ sender: Any) {
        guard let array = tableView.indexPathsForSelectedRows else {return}
        let reversedArray = array.reversed()
        for indexPath in reversedArray {
            removeMediaItem(atIndex: indexPath.row)
        }
        self.navigationItem.leftBarButtonItem = syncBarButtonItem
    }
    
    @objc private func didTapSyncButton(_ sender: Any) {
        fetchLocalItems()
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

    func startPlay(atIndex index: Int, autoPlay autoplay: Bool = true) {
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

    private func rewindPlayerItemTo(_ rewindTo: CMTime) {
        guard player.currentItem != nil else {return}
        player.seek(to: rewindTo) { [weak self] (flag) in
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
    
    private func removeMediaItem(atIndex index: Int) {
        let removedObject = itemsArray.remove(at: index)
        itemsSet.remove(removedObject)
        tableView.reloadData()
        CoreManager.shared.coreManagerContext.delete(removedObject)
        saveChanges()
        
        if !FileManager.default.removeFileFromApplicationSupportDirectory(withName: removedObject.displayFileName) {
            showErrorAlertWithMessageByKey("Alert.Message.Can'tRemove")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MusicViewController: PlayerViewDelegate {
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
            self.itemsArray = Array(itemsSet)
        }else{
            self.itemsArray = self.itemsSet.filter({ (musicItem) -> Bool in
                return musicItem.displayFileName.contains(trimmedString)
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
            let request = Music.StartPlayOrDownload.Request(index: indexPath.row)
            interactor?.startPlayOrDownload(request: request)
            tableView.deselectRow(at: indexPath, animated: true)
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
            self?.removeMediaItem(atIndex: indexPath.row)
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
        if musicItemsArray.isEmpty {
            let emptyView = EmptyMusicListView.loadFromNib()
            tableView.backgroundView = emptyView
            emptyView.startAnimation()
        } else {
            tableView.backgroundView = nil
        }
        return musicItemsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as? VideoAndMusicTableViewCell else {
            return UITableViewCell()
        }
        cell.setDataInCell(item: musicItemsArray[indexPath.row])
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
        //TODO: add logic for save index for item and after that implement logic for move items
//        let movedMusicItem = itemsArray[sourceIndexPath.row]
//        itemsArray.remove(at: sourceIndexPath.row)
//        movedMusicItem.isNew = false
//        itemsArray.insert(movedMusicItem, at: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeMediaItem(atIndex: indexPath.row)
        }
    }
}

extension MusicViewController: MusicDisplayLogic {
    func displayMusicItemsArray(viewModel: Music.FetchLocalItems.ViewModel) {
        musicItemsArray = viewModel.musicDisplayDataArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func unnewMusicItem(viewModel: Music.StartPlayOrDownload.ViewModel) {
        musicItemsArray[viewModel.atIndex] = viewModel.musicItem
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: viewModel.atIndex, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .middle)
        }
    }
    
    func updatePlaynigSongInfo(viewModel: Music.UpdatePlayingSongInfo.ViewModel) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = viewModel.info.getLikeDictForSystem()
        playerView.updateViewWith(info: viewModel.info)
    }
}
