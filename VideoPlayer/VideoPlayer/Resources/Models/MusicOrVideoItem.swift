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

    init(fileName: String, isNew: Bool = false, stoppedTime: Double? = nil, localIdOptional: String? = nil, uploadedToCloud: Bool = false) {
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
    }

    @nonobjc public func fetchRequest() -> NSFetchRequest<MusicOrVideoItem> {
        return NSFetchRequest<MusicOrVideoItem>(entityName: "MusicOrVideoItem")
    }
}
