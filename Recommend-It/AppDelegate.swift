//
//  AppDelegate.swift
//  Recommend-It
//
//  Created by Derrick Showers on 4/20/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // **********************************
        // SETUP APP
        // **********************************

        window = UIWindow(frame: UIScreen.main.bounds)

        // setup initial storyboard
        let sb = UIStoryboard(name: "Feed", bundle: nil)
        let sbvc = sb.instantiateInitialViewController()! as UIViewController
        window!.rootViewController = sbvc
        window!.makeKeyAndVisible()

        return true
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        if !hasDataBeenMigrated() {
            migrateData()
            cleanupFromOldVersion()
        }

        return true
    }

    private func hasDataBeenMigrated() -> Bool {
        let fileManager = FileManager.default
        return !fileManager.fileExists(atPath: documentsUrlForFile(fileName: "RecommendIt.sqlite"))
    }

    private func migrateData() {
        var locationEntity: [Location]?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")

        do {
            locationEntity = try getOldDB().fetch(fetchRequest) as? [Location]
        }
        catch {
            print("An error occured fetching from Core Data")
        }

        guard let oldEntity = locationEntity else { return }

        oldEntity.forEach { entity in
            let rec = CoreDataManager.sharedInstance.newItem(entityName: "Recommendation")

            rec.setValue(entity.archived, forKey: "archived")
            rec.setValue(entity.city, forKey: "location")
            rec.setValue(entity.image, forKey: "image")
            rec.setValue(entity.name, forKey: "name")
            rec.setValue(entity.notes, forKey: "notes")
            rec.setValue(entity.yelpId, forKey: "yelpId")
            rec.setValue(entity.recommendedBy, forKey: "recommendedBy")
        }

        CoreDataManager.sharedInstance.saveContext()
    }

    private func cleanupFromOldVersion() {
        let fileManager = FileManager.default

        try? fileManager.removeItem(at: URL(fileURLWithPath: documentsUrlForFile(fileName: "RecommendIt.sqlite")))
        try? fileManager.removeItem(at: URL(fileURLWithPath: documentsUrlForFile(fileName: "RecommendIt.sqlite-shm")))
        try? fileManager.removeItem(at: URL(fileURLWithPath: documentsUrlForFile(fileName: "RecommendIt.sqlite-wal")))

    }

    private func getOldDB() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "RecommendIt")
        let url = URL(fileURLWithPath: documentsUrlForFile(fileName: "RecommendIt.sqlite"))
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container.viewContext
    }

    private func documentsUrlForFile(fileName: String) -> String {
        return "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(fileName)"
    }
}
