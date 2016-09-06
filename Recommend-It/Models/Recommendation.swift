//
//  Recommendation.swift
//  Recommend-It
//
//  Created by Derrick Showers on 5/5/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation

/**
    A recommendation is something that is already saved by the user, not to be confused
    with what is returned by Yelp (a `YelpBiz` object)
*/
class Recommendation {
    let yelpId: String
    var name: String
    var thumbnail: NSData?
    var notes: String?
    var location: String?
    var archived = false

    init(yelpId: String, name: String) {
        self.yelpId = yelpId
        self.name = name
    }
}
