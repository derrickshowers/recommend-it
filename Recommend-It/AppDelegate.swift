//
//  AppDelegate.swift
//  Recommend-It
//
//  Created by Derrick Showers on 4/20/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var recommendationStore = RecommendationStore()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // **********************************
        // SETUP APP
        // **********************************

        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        // setup initial storyboard
        let sb = UIStoryboard(name: "Feed", bundle: nil)
        let sbvc = sb.instantiateInitialViewController()! as UIViewController
        window!.rootViewController = sbvc
        window!.makeKeyAndVisible()

        return true
    }
}
