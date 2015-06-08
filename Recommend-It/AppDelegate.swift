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
        
        YelpAPI.sharedInstance.getBusinessesByLocationAndTerm(location: "San Francisco", term: "Seafood") { (businesses: [YelpBiz]) -> Void in
            println(businesses)
        }
        
        YelpAPI.sharedInstance.getBusinessesByLocationAndTerm(location: "San Francisco", term: "Burgers") { (businesses: [YelpBiz]) -> Void in
            println(businesses)
        }

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // need to figure out a way to pass data around the app, specifically the
        // recommendations array. This article looks worth reading to get a start: 
        // http://iphonedevsdk.com/forum/iphone-sdk-development/54859-sharing-data-between-view-controllers-other-objects.html
        // 
        // but for now, let's create some fake data here...
        var rec1 = recommendationStore.createRecommendation(yelpId: "bits-and-bops", name: "Bits & Bops Boutique")
        rec1.notes = "This place is all about bits and bops. Recommended by some person"
        var rec2 = recommendationStore.createRecommendation(yelpId: "mels-diner", name: "Mel's Diner")
        rec2.notes = "A diner full of yummy goodness!"
        var rec3 = recommendationStore.createRecommendation(yelpId: "wag-tail", name: "Wag Tail")
        rec3.notes = "Some place that sells dog stuff, hence the name."
        var rec4 = recommendationStore.createRecommendation(yelpId: "brain-food", name: "Brain Food, Inc.")
        rec4.notes = "Food for brainz... :)"

        // setup initial storyboard
        let sb = UIStoryboard(name: "Feed", bundle: nil)
        let sbvc = sb.instantiateInitialViewController() as! UIViewController
        window!.rootViewController = sbvc
        window!.makeKeyAndVisible()

        return true
    }

}

