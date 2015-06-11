//
//  RecommendationStore.swift
//  Recommend-It
//
//  Created by Derrick Showers on 5/5/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation

class RecommendationStore {
    var allRecommendations = [Recommendation]()
    
    // public method to create a recommendation, returns the new recommendation
    func createRecommendation(#yelpId: String, name: String) -> Recommendation {
        let rec = Recommendation(yelpId: yelpId, name: name)
        allRecommendations.append(rec)
        return rec
    }
    
    // public method to get a recommendation based on name (to modify?)
    func getRecommendation(#name: String) -> Recommendation? {
        var recommendation: Recommendation?
        for rec in allRecommendations {
            if rec.name == name {
                recommendation = rec
            }
        }
        return recommendation
    }
}