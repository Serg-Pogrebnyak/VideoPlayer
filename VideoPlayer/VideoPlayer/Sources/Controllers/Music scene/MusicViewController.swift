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
    func displayMusicItemsArrayAfterDeleting(viewModel: Music.DeleteMediaItem.ViewModel)
    func displayMusicItemsArrayAfterSearch(viewModel: Music.FindMediaItems.ViewModel)
}

final class MusicViewController: UIViewController {
    
    private enum NavigationBarButtonState {
        case normal // in this mode display sync and edit buttons
        case tableViewEditing(Int) // in this mode display sync/delete and cancel buttons
        case searching // in this mode display sync and cancel buttons
    }
    
    // MARK: Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var playerView: PlayerView!
    @IBOutlet private weak var fromBottomToTopPlayerViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playerViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Variables
    //navigation UI elements
    private var syncBarButtonItem: UIBarButtonItem!
    private var deleteBarButtonItem: UIBarButtonItem!
    private var editBarButtonItem: UIBarButtonItem!
    private var cancelBarButtonItem: UIBarButtonItem!
    lazy private var searchBar = UISearchBar(frame: CGRect.zero)
    
    private var navigationBarState = NavigationBarButtonState.normal {
        didSet {
            setupNavigationBarButons()
        }
    }
    private var interactor: MusicBusinessLogic?
    private var routerInput: MusicRouterInput?
    private var musicItemsArray = [Music.MusicDisplayData]()
    
    //TODO: remove variables below
    private var itemsArray = [MusicOrVideoItem]()
    private let rewind = CMTime(seconds: 15, preferredTimescale: 1)
    private var player = AVPlayer()
    private var nowPlayingInfo = [String: Any]()
    private var indexOfCurrentItem: Int?
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCleanCycle()
        playerView.delegat = self
        setupRemoteCommandCenter()
        //FileManager.default.removeAllFromTempDirectory()
        setupUI()
        setupNavigationBarButons()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedToForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLocalItems()
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
        let router = MusicRouter()
        viewController.routerInput = router
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
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
        
        //setup player view
        playerView.setUpPropertyForAnimation(allHeight: playerViewHeightConstraint.constant,
                                             notVizibleHeight: playerViewHeightConstraint.constant - fromBottomToTopPlayerViewConstraint.constant)
    }
    
    private func setupNavigationBarButons() {
        let deleteTitle = LocalizationManager.shared.getText("NavigationBar.deleteButton.title")
        //init navigation bar buttons
        if  syncBarButtonItem == nil ||
            deleteBarButtonItem == nil ||
            editBarButtonItem == nil ||
            cancelBarButtonItem == nil
        {
            syncBarButtonItem = UIBarButtonItem(title: LocalizationManager.shared.getText("NavigationBar.syncButton.title"),
                                                 style: .done,
                                                 target: self,
                                                 action: #selector(didTapSyncButton))
            syncBarButtonItem.image = UIImage.init(named: "sync")
            syncBarButtonItem.tintColor = UIColor.barColor
            
            deleteBarButtonItem = UIBarButtonItem(title: deleteTitle,
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(didTapDeleteButton))
            deleteBarButtonItem.tintColor = UIColor.red
            
            editBarButtonItem = UIBarButtonItem(title: "Edit",
                                                style: .done,
                                                target: self,
                                                action: #selector(didTapEditButton))
            editBarButtonItem.image = UIImage.init(named: "Edit")
            editBarButtonItem.tintColor = UIColor.barColor
            
            cancelBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                   style: .done,
                                                   target: self,
                                                   action: #selector(didTapCancelButton))
            cancelBarButtonItem.image = UIImage.init(named: "Cancel")
            cancelBarButtonItem.tintColor = UIColor.barColor
        }
        
        switch navigationBarState {
        case .normal:
            navigationItem.leftBarButtonItem = syncBarButtonItem
            navigationItem.rightBarButtonItem = editBarButtonItem
        case .searching:
            navigationItem.leftBarButtonItem = syncBarButtonItem
            navigationItem.rightBarButtonItem = cancelBarButtonItem
        case .tableViewEditing(let count):
            if count <= 0 {
                navigationItem.leftBarButtonItem = nil
            } else {
                deleteBarButtonItem.title = deleteTitle + " " + String(count)
                navigationItem.leftBarButtonItem = deleteBarButtonItem
            }
            navigationItem.rightBarButtonItem = cancelBarButtonItem
        }
    }
    
    //MARK: navigation title and button actions
    @objc private func didTapDeleteButton(_ sender: Any) {
        guard   let array = tableView.indexPathsForSelectedRows,
                let interactor = interactor
        else { return }
        
        let reversedArray = array.sorted().reversed()
        for indexPath in reversedArray {
            let request = Music.DeleteMediaItem.Request(localId: musicItemsArray[indexPath.row].localId)
            interactor.removeMediaItem(request: request)
        }
        
        navigationBarState = .tableViewEditing(0)
    }
    
    @objc private func didTapSyncButton(_ sender: Any) {
        routerInput?.routeToSyncMusicViewController()
    }
    
    @objc private func didTapEditButton(_ sender: Any) {
        tableView.isEditing = true
        navigationBarState = .tableViewEditing(0)
    }
    
    @objc private func didTapCancelButton(_ sender: Any) {
        self.view.endEditing(true)
        navigationItem.titleView = nil
        tableView.isEditing = false
        navigationBarState = .normal
    }
    
    @objc private func titleWasTapped() {
        tableView.isEditing = false
        if navigationItem.titleView == nil {
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
            navigationBarState = .searching
        } else {
            navigationBarState = .normal
        }
    }
    
    // MARK: Do some business logic
    private func fetchLocalItems() {
        let request = Music.FetchLocalItems.Request()
        interactor?.fetchLocalItems(request: request)
    }
    
    // MARK: setup remote command for display buttons on lock screen and in menu
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
    
    // TODO: remove this two functions in future
    func startPlay(atIndex index: Int, autoPlay autoplay: Bool = true) {
    }
    
    private func rewindPlayerItemTo(_ rewindTo: CMTime) {
        guard player.currentItem != nil else {return}
        player.seek(to: rewindTo) { [weak self] (flag) in
        }
    }
    //
    
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
        tableView.setContentOffset(.zero, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request = Music.FindMediaItems.Request(searchText: searchText)
        interactor?.findMediaItems(request: request)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

extension MusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let countOfSelected = tableView.indexPathsForSelectedRows?.count ?? 0
            navigationBarState = .tableViewEditing(countOfSelected)
        } else {
            let request = Music.StartPlayOrDownload.Request(index: indexPath.row)
            interactor?.startPlayOrDownload(request: request)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let countOfSelected = tableView.indexPathsForSelectedRows?.count ?? 0
            navigationBarState = .tableViewEditing(countOfSelected)
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .destructive, title: "") { [weak self] (action, indexPath) in
            guard let self = self else {return}
            let request = Music.DeleteMediaItem.Request(localId: self.musicItemsArray[indexPath.row].localId)
            self.interactor?.removeMediaItem(request: request)
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

    //MARK: - Table view cell editing
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
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
            let request = Music.DeleteMediaItem.Request(localId: musicItemsArray[indexPath.row].localId)
            interactor?.removeMediaItem(request: request)
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
    
    func displayMusicItemsArrayAfterDeleting(viewModel: Music.DeleteMediaItem.ViewModel) {
        musicItemsArray = viewModel.musicDisplayDataArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func displayMusicItemsArrayAfterSearch(viewModel: Music.FindMediaItems.ViewModel) {
        musicItemsArray = viewModel.musicDisplayDataArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MusicViewController: SyncMusicViewControllerDelegate {
    func willDisappearSyncViewController() {
        fetchLocalItems()
    }
}
