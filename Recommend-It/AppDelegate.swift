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

        migrateData()

        return true
    }

    private func migrateData() {
        let locationEntity: [Location] = CoreDataManager.sharedInstance.fetchEntity(entityName: "Location")

        locationEntity.forEach { Location in
            let rec = CoreDataManager.sharedInstance.newItem(entityName: "Recommendation")

            rec.setValue(Location.archived, forKey: "archived")
            rec.setValue(Location.city, forKey: "location")
            rec.setValue(Location.image, forKey: "image")
            rec.setValue(Location.name, forKey: "name")
            rec.setValue(Location.notes, forKey: "notes")
            rec.setValue(Location.yelpId, forKey: "yelpId")
            rec.setValue(Location.recommendedBy, forKey: "recommendedBy")
        }

        CoreDataManager.sharedInstance.saveContext()
    }
}
