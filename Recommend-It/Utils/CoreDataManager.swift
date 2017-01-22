//
//  CoreDataManager.swift
//  Recommend-It
//
//  Created by Derrick Showers on 10/19/16.
//  Copyright © 2016 Derrick Showers. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {

    static let sharedInstance = CoreDataManager()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RecommendIt")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func newItem<Entity: NSManagedObject>(entityName: String) -> Entity {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: persistentContainer.viewContext)
        return NSManagedObject(entity: entity!, insertInto: persistentContainer.viewContext) as! Entity
    }

    func deleteItem<Entity: NSManagedObject>(item: Entity) {
        persistentContainer.viewContext.delete(item)
    }

    func fetchEntity<Entity>(entityName: String) -> [Entity] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var results = [Entity]()

        do {
            results = try persistentContainer.viewContext.fetch(fetchRequest) as! [Entity]
        }
        catch {
            print("An error occured fetching from Core Data")
        }

        return results
    }
}
