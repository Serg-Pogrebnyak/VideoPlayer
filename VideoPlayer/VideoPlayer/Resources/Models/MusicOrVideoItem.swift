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

final class MusicOrVideoItem: NSManagedObject {
    
    @NSManaged public var displayFileName: String
    @NSManaged public var fileNameInStorage: String
    @NSManaged public var isNew: Bool
    @NSManaged public var uploadedToCloud: Bool
    @NSManaged public var stoppedTime: NSNumber?
    @NSManaged public var localId: String
    @NSManaged public var remoteId: String?

    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(fileName: String, fileExtension: String) {
        let entity = NSEntityDescription.entity(forEntityName: "MusicOrVideoItem", in: CoreManager.shared.coreManagerContext)!
        super.init(entity: entity, insertInto: CoreManager.shared.coreManagerContext)
        self.displayFileName = fileName
        let newUUID = UUID().uuidString
        self.fileNameInStorage = newUUID + fileExtension
        self.isNew = true
        self.remoteId = nil
        self.stoppedTime = nil
        self.localId = newUUID
    }

    @nonobjc public func fetchRequest() -> NSFetchRequest<MusicOrVideoItem> {
        return NSFetchRequest<MusicOrVideoItem>(entityName: "MusicOrVideoItem")
    }
}
