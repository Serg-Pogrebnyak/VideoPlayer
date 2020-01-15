//
//  MusicViewController.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import UIKit
import Foundation

class MusicViewController: UIViewController, MusicOrVideoArrayProtocol {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    internal var itemsArray = [MusicOrVideoItem]()
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
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        if tableView.isEditing {
             saveChanges()
         }
        tableView.isEditing = !tableView.isEditing
    }

    func startPlay(atIndex index: Int) {
        print("start music")//TODO: add audio logic
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
            let musicItem = MusicOrVideoItem.init(filename: URLofMusic.lastPathComponent)
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
