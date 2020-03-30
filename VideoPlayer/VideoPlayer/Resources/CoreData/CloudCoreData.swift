//
//  CloudCoreData.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 30.03.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import CloudKit

class CloudCoreData {
    
    private static let publicCloudDataBase = CKContainer.default().publicCloudDatabase
    
    static func pushAllDataBaseToCloud() {
        let localObjectsArray = CoreManager.shared.getElementsArray() ?? [MusicOrVideoItem]()
        
        for item in localObjectsArray {
            let musicOrVideoRecod = CKRecord(recordType: "MusicOrVideoItem")
            
            musicOrVideoRecod.setValue(item.fileName, forKey: "fileName")
            musicOrVideoRecod.setValue(item.isNew ? 1 : 0, forKey: "isNew")
            musicOrVideoRecod.setValue(item.stoppedTime, forKey: "stoppedTime")

            publicCloudDataBase.save(musicOrVideoRecod) { (savedRecorded, error) in
                if error == nil {
                    print("✅work")
                } else {
                    print("❌error")
                }
            }
        }
    }
    
    static func fetchAllRecords(compleation: (() -> Void)? = nil) {
        let query = CKQuery(recordType: "MusicOrVideoItem", predicate: NSPredicate(value: true))
        
        publicCloudDataBase.perform(query, inZoneWith: nil) { (optionalRecordsArray, error) in
            guard let recordsArray = optionalRecordsArray, error == nil else {return}
            
            for item in recordsArray {
                let isNew = (item.value(forKey: "isNew") as! Int) == 1 ? true : false
                let record = MusicOrVideoItem(fileName: item.value(forKey: "fileName") as! String,
                                 isNew: isNew,
                                 stoppedTime: item.value(forKey: "stoppedTime") as? Double)
                CoreManager.shared.saveContext()
            }
            compleation?()
        }
    }
}
