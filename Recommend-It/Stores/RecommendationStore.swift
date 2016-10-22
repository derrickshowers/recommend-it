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
    var allRecommendations: [Recommendation] {
        return CoreDataManager.sharedInstance.fetchEntity(entityName: "Recommendation")
    }

    static let sharedInstance = RecommendationStore()

    func createRecommendation(yelpId: String, name: String, notes: String?, location: String?) -> Recommendation? {

        let rec = CoreDataManager.sharedInstance.newItem(entityName: "Recommendation")

        rec.setValue(false, forKey: "archived")
        rec.setValue(yelpId, forKey: "yelpId")
        rec.setValue(name, forKey: "name")
        rec.setValue(notes, forKey: "notes")

        if let location = location {
            rec.setValue(location, forKey: "location")
        }

        return rec as? Recommendation
    }

    func updateImageForRecommendation(_ recommendation: Recommendation, image: NSData?) {
        guard let image = image else { return }

        if let recommendationName = recommendation.name {
            getRecommendation(name: recommendationName)?.image = image
            CoreDataManager.sharedInstance.saveContext()
        }
    }

    func getRecommendation(name: String) -> Recommendation? {
        var recommendation: Recommendation?
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
