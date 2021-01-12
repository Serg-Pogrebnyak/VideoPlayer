//
//  CoreManager.swift
//  VideoPlayer
//
//  Created by Sergey Pogrebnyak on 12.02.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation
import CoreData

class CoreManager {
    static var shared = CoreManager()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var coreManagerContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func getMediaItems() -> Set<MusicOrVideoItem> {
        do {
            let arrayOfItems = try self.coreManagerContext.fetch(MusicOrVideoItem.fetchRequest())
            if let arrayOfMediaItems = arrayOfItems as? [MusicOrVideoItem] {
                return Set(arrayOfMediaItems.map { $0 })
            } else {
                //TODO: write cast error
                return Set<MusicOrVideoItem>()
            }
        } catch {
            //TODO: write error
            let nserror = error as NSError
            return Set<MusicOrVideoItem>()
        }

    }

    // MARK: - Core Data Saving support
    func saveContext () {
        guard coreManagerContext.hasChanges else {return}
        coreManagerContext.perform {
            do {
                try self.coreManagerContext.save()
                print("✅saved")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
