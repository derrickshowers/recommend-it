//
//  Recommendation.swift
//  Recommend-It
//
//  Created by Derrick Showers on 1/21/17.
//  Copyright © 2017 Derrick Showers. All rights reserved.
//

import Foundation
import CloudKit

// TODO: Rename this to something cloudkit specific
protocol Model {
    var className: String { get }
    static var className: String { get }
    static func buildModelFromRecord(_ record: CKRecord) -> Model?
    static func buildRecordFromModel(_ model: Model) -> CKRecord?
}

class Recommendation: Model {
    let yelpId: String
    let name: String
    var notes: String?
    var location: String?
    var thumbnailURL: String?
    var archived: Bool? = false
    var cloudKitRecordId: CKRecordID?

    init(yelpId: String, name: String, notes: String?, location: String?, thumbnailURL: String?, cloudKitRecordId: CKRecordID? = nil) {
        self.yelpId = yelpId
        self.name = name
        self.notes = notes
        self.location = location
        self.thumbnailURL = thumbnailURL
        self.cloudKitRecordId = cloudKitRecordId
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

        return Recommendation(yelpId: yelpId, name: name, notes: record["notes"] as? String, location: record["location"] as? String, thumbnailURL: record["thumbnailURL"] as? String, cloudKitRecordId: record.recordID)
    }

    class func buildRecordFromModel(_ model: Model) -> CKRecord? {

        guard let model = model as? Recommendation else {
            return nil
        }

        let recommendation = CKRecord(recordType: "Recommendation")

        recommendation["yelpId"] = model.yelpId as CKRecordValue
        recommendation["name"] = model.name as CKRecordValue
        recommendation["notes"] = model.notes as? CKRecordValue
        recommendation["location"] = model.location as? CKRecordValue
        recommendation["thumbnailURL"] = model.thumbnailURL as? CKRecordValue
        recommendation["archived"] = NSNumber(value: model.archived ?? false) as CKRecordValue

        return recommendation
    }
}
