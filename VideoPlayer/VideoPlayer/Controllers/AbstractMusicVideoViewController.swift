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

    fileprivate var syncBarButtonItem: UIBarButtonItem!
    fileprivate var deleteBarButtonItem: UIBarButtonItem!
    fileprivate var editAndCancelBarButtonItem: UIBarButtonItem!
    fileprivate var customTableViewDelegate: CustomTableViewDelegate!
    fileprivate var customTableViewDataSource: CustomTableViewDataSource!

    //shouldbe same unique for music or video VC
    internal var emptyView: EmptyAnimatedViewProtocol!
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
        childTableView.allowsMultipleSelectionDuringEditing = true
        searchBar.delegate = self
        //add tap recognizer for search bar
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(titleWasTapped))
        self.navigationController?.navigationBar.addGestureRecognizer(recognizer)
        //create navigation bar button
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

//        CloudCoreData.fetchAllRecords(myLocalRecords: CoreManager.shared.getElementsArray() ?? [MusicOrVideoItem]()){
//            print(CoreManager.shared.getElementsArray()?.count)
//        }
        
        fetchAllItemsAndUpdateLibrary()
//        CloudCoreData.pushAllDataBaseToCloud()
    }

    fileprivate func fetchAllItemsAndUpdateLibrary() {
        itemsArray.removeAll()
        let currentLibrary: [MusicOrVideoItem] = CoreManager.shared.getElementsArray() ?? [MusicOrVideoItem]()

        let musicOrVideoURLArray = FileManager.default.getAllFilesWithExtension(directory: .documentDirectory,
                                                                                fileExtension: itemExtension) ?? [URL]()

        for URLofItem in musicOrVideoURLArray {
            var flag = true
            for item in currentLibrary {
                if item.fileName == URLofItem.lastPathComponent {
                    flag = false
                    break
                }
            }
            if flag {
                let musicItem = MusicOrVideoItem.init(fileName: URLofItem.lastPathComponent)
                musicItem.isNew = true
                itemsArray.append(musicItem)
            }
        }
        itemsArray = itemsArray + currentLibrary
        if itemsArray.count != musicOrVideoURLArray.count {
            for item in itemsArray {
                guard !musicOrVideoURLArray.contains(where: {$0.lastPathComponent == item.fileName}) else {continue}
                let index = itemsArray.firstIndex(of: item)
                let removedObject = itemsArray.remove(at: index!)
                CoreManager.shared.coreManagerContext.delete(removedObject)
            }
        }
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

    func setSomeParameter(tableView table: UITableView, userDefaultsKey: String, itemExtension: String, view: EmptyAnimatedViewProtocol) {
        emptyView = view
        childTableView = table
        itemUserDefaultsKey = userDefaultsKey
        self.itemExtension = itemExtension
    }

    func startPlay(atIndex index: Int, autoPlay autoplay: Bool) {
    }

    func selectedItems(count: Int) {
        if count > 0 {
            let buttonTitle = LocalizationManager.shared.getText("NavigationBar.deleteButton.title")
            deleteBarButtonItem.title = buttonTitle + "(\(count))"
            self.navigationItem.leftBarButtonItem = deleteBarButtonItem
        } else {
            self.navigationItem.leftBarButtonItem = syncBarButtonItem
        }
    }

    func removeItem(atIndex index: Int) {
        do {
            let url = FileManager.default.getURLS().appendingPathComponent(itemsArray[index].fileName, isDirectory: false)
            try FileManager.default.removeItem(at: url)
            let removedObject = itemsArray.remove(at: index)
            filterItemsArray.remove(at: index)
            childTableView.reloadData()
            CoreManager.shared.coreManagerContext.delete(removedObject)
            saveChanges()
        } catch {
            showErrorAlertWithMessageByKey("Alert.Message.Can'tRemove")
        }
    }

    internal func saveChanges() {
        CoreManager.shared.saveContext()
    }

    //MARK: - fileprivate functions
    //bar batton actions--------------------------------------------------------------------------------------------------
    @objc fileprivate func didTapDeleteButton(_ sender: Any) {
        guard let array = childTableView.indexPathsForSelectedRows else {return}
        let reversedArray = array.reversed()
        for indexPath in reversedArray {
            removeItem(atIndex: indexPath.row)
        }
        self.navigationItem.leftBarButtonItem = syncBarButtonItem
    }
    @objc fileprivate func didTapSyncButton(_ sender: Any) {
        fetchAllItemsAndUpdateLibrary()
    }
    @objc fileprivate func didTapEditAndCancelButton(_ sender: Any) {
        switch navigationBarState {
        case .cancel:
            self.view.endEditing(true)
            navigationBarState = .edit
            editAndCancelBarButtonItem.image = UIImage.init(named: navigationBarState.rawValue)
            editAndCancelBarButtonItem.title = navigationBarState.rawValue
            navigationItem.titleView = nil
        case .edit:
            self.navigationItem.leftBarButtonItem = syncBarButtonItem
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
    //finished bar batton actions------------------------------------------------------------------------------------------

    fileprivate func setupTableViewDelegateAndDataSource() {
        customTableViewDelegate = CustomTableViewDelegate(protocolObject: self)
        customTableViewDataSource = CustomTableViewDataSource(protocolObject: self, emptyView: emptyView)
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
