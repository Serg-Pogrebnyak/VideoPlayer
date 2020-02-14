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
    @NSManaged public var stoppedTime: NSNumber?

    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(fileName: String, isNew: Bool = false, stoppedTime: Double? = nil) {
        let entity = NSEntityDescription.entity(forEntityName: "MusicOrVideoItem", in: CoreManager.shared.coreManagerContext)!
        super.init(entity: entity, insertInto: CoreManager.shared.coreManagerContext)
        self.fileName = fileName
        self.isNew = isNew
        if let time = stoppedTime {
            self.stoppedTime = time as NSNumber
        } else {
            self.stoppedTime = nil
        }
    }

    @nonobjc public func fetchRequest() -> NSFetchRequest<MusicOrVideoItem> {
        return NSFetchRequest<MusicOrVideoItem>(entityName: "MusicOrVideoItem")
    }
}
