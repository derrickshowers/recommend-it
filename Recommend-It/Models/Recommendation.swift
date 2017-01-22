//
//  Recommendation.swift
//  Recommend-It
//
//  Created by Derrick Showers on 1/21/17.
//  Copyright © 2017 Derrick Showers. All rights reserved.
//

import Foundation
import CloudKit

protocol Model {
    var className: String { get }
    static var className: String { get }
    static func buildModelFromRecord(_ record: CKRecord) -> Model?
}

class Recommendation: Model {
    let yelpId: String
    let name: String
    var notes: String?
    var location: String?
    var thumbnailURL: String?
    var archived: Bool? = false

    init(yelpId: String, name: String, notes: String?, location: String?, thumbnailURL: String?) {
        self.yelpId = yelpId
        self.name = name
        self.notes = notes
        self.location = location
        self.thumbnailURL = thumbnailURL
    }

    var className: String {
        return String(describing: type(of: self))
    }

    class var className: String {
        return String(describing: self)
    }

    class func buildModelFromRecord(_ record: CKRecord) -> Model? {
        guard let yelpId = record["yelpId"] as? String,
            let name = record["name"] as? String else {
                return nil
        }

        return Recommendation(yelpId: yelpId, name: name, notes: record["notes"] as? String, location: record["location"] as? String, thumbnailURL: record["thumbnailURL"] as? String)
    }
}
