//
//  Recommendation.swift
//  Recommend-It
//
//  Created by Derrick Showers on 5/5/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation

class Recommendation {
    let yelpId: String
    let name: String
    var thumbnail: NSData?
    var notes: String?
    var archived = false
    
    init(yelpId: String, name: String) {
        self.yelpId = yelpId
        self.name = name
    }
}