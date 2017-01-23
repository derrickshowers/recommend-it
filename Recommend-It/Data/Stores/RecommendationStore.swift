//
//  RecommendationStore.swift
//  Recommend-It
//
//  Created by Derrick Showers on 5/5/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RecommendationStore {

    /// MARK: - Properties
    var allRecommendations: [OldRecommendation] {
        return CoreDataManager.sharedInstance.fetchEntity(entityName: "Recommendation").filter({ !$0.archived })
    }

    static let sharedInstance = RecommendationStore()

    func createRecommendation(yelpId: String, name: String, notes: String?, location: String?, thumbnailURL: String?) -> OldRecommendation? {

        let rec = CoreDataManager.sharedInstance.newItem(entityName: "Recommendation")

        rec.setValue(false, forKey: "archived")
        rec.setValue(yelpId, forKey: "yelpId")
        rec.setValue(name, forKey: "name")
        rec.setValue(notes, forKey: "notes")
        rec.setValue(thumbnailURL, forKey: "thumbnailURL")
        rec.setValue(location, forKey: "location")

        CoreDataManager.sharedInstance.saveContext()

        return rec as? OldRecommendation
    }

    func getRecommendation(name: String) -> OldRecommendation? {
        var recommendation: OldRecommendation?
        for rec in allRecommendations {
            if rec.name == name {
                recommendation = rec
            }
        }
        return recommendation
    }

    func removeRecommendation(at: Int) {
        let rec = allRecommendations[at]
        CoreDataManager.sharedInstance.deleteItem(item: rec)
        CoreDataManager.sharedInstance.saveContext()
    }
}
