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
            guard !item.uploadedToCloud else {continue}
            let musicOrVideoRecod = CKRecord(recordType: "MusicOrVideoItem")
            
            musicOrVideoRecod.setValue(item.fileName, forKey: "fileName")
            musicOrVideoRecod.setValue(item.isNew ? 1 : 0, forKey: "isNew")
            musicOrVideoRecod.setValue(item.stoppedTime, forKey: "stoppedTime")
            musicOrVideoRecod.setValue(item.localId, forKey: "localId")

            publicCloudDataBase.save(musicOrVideoRecod) { (savedItemOptional, error) in
                guard error == nil, let savedItem = savedItemOptional else {return}
                let localObjectsArray = CoreManager.shared.getElementsArray() ?? [MusicOrVideoItem]()
                for item in localObjectsArray {
                    if item.localId == (savedItem.value(forKey: "localId") as! String) {
                        item.uploadedToCloud = true
                        break
                    }
                }
                CoreManager.shared.saveContext()
                if error == nil {
                    print("✅work")
                } else {
                    print("❌error")
                }
            }
        }
    }
    
    static func fetchAllRecords(myLocalRecords records: [MusicOrVideoItem], compleation: (() -> Void)? = nil) {
        let query = CKQuery(recordType: "MusicOrVideoItem", predicate: NSPredicate(value: true))
        
        publicCloudDataBase.perform(query, inZoneWith: nil) { (optionalRecordsArray, error) in
            guard let recordsArray = optionalRecordsArray, error == nil else {return}
            var newRecords = [MusicOrVideoItem]()
            for item in recordsArray {
                let localId = item.value(forKey: "localId") as! String
                guard isThisNewElement(myLocalRecords: records, id: localId) else {continue}
                
                let isNew = (item.value(forKey: "isNew") as! Int) == 1 ? true : false
                let record = MusicOrVideoItem(fileName: item.value(forKey: "fileName") as! String,
                                 isNew: isNew,
                                 stoppedTime: item.value(forKey: "stoppedTime") as? Double,
                                 localIdOptional: localId,
                                 uploadedToCloud: true)
                newRecords.append(record)
            }
            CoreManager.shared.saveContext()
            compleation?()
        }
    }
    
    static private func isThisNewElement(myLocalRecords: [MusicOrVideoItem], id: String) -> Bool {
        for localItem in myLocalRecords {
            if localItem.localId == id {
                return false
            }
        }
        return true
    }
}
