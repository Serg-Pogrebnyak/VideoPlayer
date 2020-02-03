//
//  AbstractMusicVideoViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 30.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit

class AbstractMusicVideoViewController: UIViewController, MusicOrVideoArrayProtocol {

    internal enum NavigationBarButtonStateEnum: String {
        case edit = "Edit"
        case cancel = "Cancel"
    }
    //same property
    lazy internal var searchBar = UISearchBar(frame: CGRect.zero)

    internal var itemsArray = [MusicOrVideoItem]()
    internal var filterItemsArray = [MusicOrVideoItem]()
    internal var navigationBarState = NavigationBarButtonStateEnum.edit
    internal var indexOfCurrentItem: Int?

    fileprivate var editAndCancelBarButtonItem: UIBarButtonItem!
    fileprivate var customTableViewDelegate: CustomTableViewDelegate!
    fileprivate var customTableViewDataSource: CustomTableViewDataSource!

    //shouldbe same unique for music or video VC
    internal var itemUserDefaultsKey: String!
    internal var itemExtension: String!
    fileprivate var childTableView: UITableView! {
        didSet {
            setupTableViewDelegateAndDataSource()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAllWasSet()
        searchBar.delegate = self
        //add tap recognizer for search bar
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(titleWasTapped))
        self.navigationController?.navigationBar.addGestureRecognizer(recognizer)
        //create navigation bar button
        editAndCancelBarButtonItem = UIBarButtonItem(title: navigationBarState.rawValue,
                                                     style: .done,
                                                     target: self,
                                                     action: #selector(didTapEditAndCancelButton))
        editAndCancelBarButtonItem.image = UIImage.init(named: navigationBarState.rawValue)
        editAndCancelBarButtonItem.tintColor = UIColor.barColor
        self.navigationItem.rightBarButtonItem = editAndCancelBarButtonItem
        fetchAllItemsAndUpdateLibrary()
    }

    fileprivate func fetchAllItemsAndUpdateLibrary() {
        var currentLibrary = [MusicOrVideoItem]()
        if let data = UserDefaults.standard.value(forKey: itemUserDefaultsKey) as? Data {
            if let items = try? PropertyListDecoder().decode(Array<MusicOrVideoItem>.self, from: data) {
                currentLibrary = items
            }
        }

        let musicURLArray = FileManager.default.getAllFilesWithExtension(directory: .documentDirectory,
                                                                         fileExtension: itemExtension) ?? [URL]()

        for URLofMusic in musicURLArray {
            var musicItem = MusicOrVideoItem.init(fileName: URLofMusic.lastPathComponent)
            if !currentLibrary.contains(musicItem) {
                musicItem.isNew = true
                itemsArray.append(musicItem)
            }
        }
        itemsArray = itemsArray + currentLibrary
        filterItemsArray = itemsArray
        saveChanges()
        childTableView.reloadData()
    }

    func unNewTrackAtIndex(_ index: Int) {
        guard itemsArray[index].isNew else {return}
        itemsArray[index].isNew = false
        saveChanges()
        childTableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .middle)
    }

    func setSomeParameter(tableView table: UITableView, userDefaultsKey: String, itemExtension: String) {
        childTableView = table
        itemUserDefaultsKey = userDefaultsKey
        self.itemExtension = itemExtension
    }

    func startPlay(atIndex index: Int, autoPlay autoplay: Bool) {

    }

    func removeItem(atIndex index: Int) {
        do {
            let url = FileManager.default.getURLS().appendingPathComponent(itemsArray[index].fileName, isDirectory: false)
            try FileManager.default.removeItem(at: url)
            itemsArray.remove(at: index)
            filterItemsArray.remove(at: index)
            childTableView.reloadData()
            saveChanges()
        } catch {
            showErrorAlertWithMessageByKey("Alert.Message.Can'tRemove")
        }
    }

    internal func saveChanges() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(itemsArray), forKey: itemUserDefaultsKey)
    }

    //MARK: - fileprivate functions
    @objc fileprivate func didTapEditAndCancelButton(_ sender: Any) {
        switch navigationBarState {
        case .cancel:
            self.view.endEditing(true)
            navigationBarState = .edit
            editAndCancelBarButtonItem.image = UIImage.init(named: navigationBarState.rawValue)
            editAndCancelBarButtonItem.title = navigationBarState.rawValue
            navigationItem.titleView = nil
        case .edit:
            if childTableView.isEditing {
                 saveChanges()
            }
            childTableView.isEditing = !childTableView.isEditing
        }
    }

    @objc fileprivate func titleWasTapped() {
        if navigationItem.titleView == nil {
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
            navigationBarState = .cancel
            editAndCancelBarButtonItem.image = UIImage.init(named: navigationBarState.rawValue)
            editAndCancelBarButtonItem.title = navigationBarState.rawValue
        }
    }

    fileprivate func setupTableViewDelegateAndDataSource() {
        customTableViewDelegate = CustomTableViewDelegate(protocolObject: self)
        customTableViewDataSource = CustomTableViewDataSource(protocolObject: self)
        childTableView.delegate = customTableViewDelegate
        childTableView.dataSource = customTableViewDataSource
        let nib = UINib.init(nibName: "VideoAndMusicTableViewCell", bundle: nil)
        childTableView.register(nib, forCellReuseIdentifier: "MusicCell")
    }

    fileprivate func checkAllWasSet() {
        assert(childTableView != nil)
        assert(itemUserDefaultsKey != nil)
        assert(itemExtension != nil)
    }
}

extension AbstractMusicVideoViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        childTableView.reloadData()
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
        childTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        childTableView.reloadData()
    }
}
