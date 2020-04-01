//
//  MusicOrVideoItem.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 14.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation
import CoreData

protocol MusicOrVideoArrayProtocol: class {
    var itemsArray: [MusicOrVideoItem] {get set}
    func startPlay(atIndex index: Int, autoPlay: Bool)
    func removeItem(atIndex index: Int)
    func selectedItems(count: Int)
}

class MusicOrVideoItem: NSManagedObject {
    @NSManaged public var fileName: String
    @NSManaged public var isNew: Bool
    @NSManaged public var uploadedToCloud: Bool
    @NSManaged public var stoppedTime: NSNumber?
    @NSManaged public var localId: String

    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(fileName: String, isNew: Bool = false, stoppedTime: Double? = nil, localIdOptional: String? = nil, uploadedToCloud: Bool = false, filePathInDocumentFolder: URL? = nil) {
        let entity = NSEntityDescription.entity(forEntityName: "MusicOrVideoItem", in: CoreManager.shared.coreManagerContext)!
        super.init(entity: entity, insertInto: CoreManager.shared.coreManagerContext)
        self.fileName = fileName
        self.isNew = isNew
        if let time = stoppedTime {
            self.stoppedTime = time as NSNumber
        } else {
            self.stoppedTime = nil
        }
        
        if let localId = localIdOptional {
            self.localId = localId
        } else {
            self.localId = UUID().uuidString
        }
        
        if filePathInDocumentFolder != nil {
            replaceItem(from: filePathInDocumentFolder!)
        }
    }

    @nonobjc public func fetchRequest() -> NSFetchRequest<MusicOrVideoItem> {
        return NSFetchRequest<MusicOrVideoItem>(entityName: "MusicOrVideoItem")
    }
    
    func replaceItem(from srcURL: URL) {
        do {
            let fileManager = FileManager.default
            let dstURL = FileManager.default.getTempDirectory().appendingPathComponent(self.fileName)
            try fileManager.copyItem(at: srcURL, to: dstURL)
            try fileManager.removeItem(at: srcURL)
        } catch let error as NSError {
            if error.code == NSFileWriteFileExistsError {
                print("Error replace file. File exists. Trying to replace")
            }
        }
    }
    
    func hasLocalFile() ->Bool {
        let fileUrl = FileManager.default.getTempDirectory().appendingPathComponent(self.fileName).path
        return FileManager.default.fileExists(atPath: fileUrl)
    }
    
    fileprivate func convertToFile(data: Data, filename: String) {
        do {
            var filePathAndName = FileManager.default.getTempDirectory().absoluteString
            filePathAndName.append(contentsOf: filename)
            //filePathAndName.append(contentsOf: ".mp3")
            let newUrl = URL(string: filePathAndName)!
            try data.write(to: newUrl)
        } catch {
            fatalError("Can't convert data to file")
        }
    }
}
