//
//  CloudCoreData.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 30.03.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import CloudKit
import CoreData

class CloudCoreData {
    
    private static let publicCloudDataBase = CKContainer.default().publicCloudDatabase
    
    static func pushAllDataBaseToCloud() {
        let localObjectsArray = CoreManager.shared.getElementsArray() ?? [MusicOrVideoItem]()

        for item in localObjectsArray {
            guard !item.uploadedToCloud else {continue}
            let fileUrl = FileManager.default.tempDirectory.appendingPathComponent(item.fileName)
            let songAsset = CKAsset(fileURL: fileUrl)
            let musicOrVideoRecod = CKRecord(recordType: "MusicOrVideoItem")
            
            musicOrVideoRecod.setValue(item.fileName, forKey: "fileName")
            musicOrVideoRecod.setValue(item.isNew ? 1 : 0, forKey: "isNew")
            musicOrVideoRecod.setValue(item.stoppedTime, forKey: "stoppedTime")
            musicOrVideoRecod.setValue(item.localId, forKey: "localId")
            musicOrVideoRecod.setValue(songAsset, forKey: "songURL")

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
        let privateQueue = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateQueue.parent = CoreManager.shared.coreManagerContext
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["fileName", "isNew", "stoppedTime", "localId"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.recordFetchedBlock = { record in
            let localId = record.value(forKey: "localId") as! String
            guard isThisNewElement(myLocalRecords: records, id: localId) else {return}


            let isNew = (record.value(forKey: "isNew") as! Int) == 1 ? true : false
            _ = MusicOrVideoItem(fileName: record.value(forKey: "fileName") as! String,
                                 isNew: isNew,
                                 stoppedTime: record.value(forKey: "stoppedTime") as? Double,
                                 localIdOptional: localId,
                                 uploadedToCloud: true,
                                 remoteId: record.recordID.recordName)
            try! privateQueue.save()
        }
        
        queryOperation.completionBlock = {
            CoreManager.shared.saveContext()
            compleation?()
        }
        publicCloudDataBase.add(queryOperation)
    }
    
    static func loadFile(recordName: String, fileName: String, completion: @escaping () -> Void) {
        let fetchOperation = CKFetchRecordsOperation.init(recordIDs: [CKRecord.ID.init(recordName: recordName)])
        fetchOperation.desiredKeys = ["songURL"]
        fetchOperation.queuePriority = .normal
        
        fetchOperation.perRecordCompletionBlock = { (record, _, error) in
            guard   error == nil,
                    let asset = record?.value(forKey: "songURL") as? CKAsset,
                    let songURL = asset.fileURL,
                    let songData = try? Data.init(contentsOf: songURL) else {return}
            FileManager.default.convertToFile(data: songData, filename: fileName)
        }

        //fetchOperation.perRecordProgressBlock//TODO: fix this
        fetchOperation.completionBlock = {
            completion()
            print("✅ success loaded data")
        }
        publicCloudDataBase.add(fetchOperation)
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
