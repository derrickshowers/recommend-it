//
//  DataProvider.swift
//  Recommend-It
//
//  Created by Derrick Showers on 1/21/17.
//  Copyright © 2017 Derrick Showers. All rights reserved.
//

import Foundation
import CloudKit

// QUESTION: How does Swift resolve conflicting classes?
class DataProvider<T: Model> {

    var completion: ((_ models: [T]) -> Void)?

    // MARK: - Public Interface

    func fetchData(privateDB: Bool, forCurrentUser: Bool, completion: @escaping (_ models: [T]) -> Void) {

        let container = CKContainer.default()
        let database = privateDB ? container.privateCloudDatabase : container.publicCloudDatabase
        self.completion = completion

        if forCurrentUser {
            // TOOD: Store userId so we don't have to make a separate request everytime
            retrieveUserRecordId() { (userId: CKRecordID) in
                let reference = CKReference(recordID: userId, action: .none)
                let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
                let query = CKQuery(recordType: T.className, predicate: predicate)
                self.performDatabaseQuery(database: database, query: query)
            }
        } else {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: T.className, predicate: predicate)
            performDatabaseQuery(database: database, query: query)
        }

    }

    // MARK - Private helpers

    private func performDatabaseQuery(database: CKDatabase, query: CKQuery) {
        database.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
            var models = [T]()
            results?.forEach({ (record: CKRecord) in

                guard let model = T.buildModelFromRecord(record) as? T else {
                    return
                }

                models.append(model)
            })

            // QUESTION: Why does weak self not work here? 🤔
            DispatchQueue.main.async() {
                self.completion?(models)
            }
        }
    }

    private func retrieveUserRecordId(completion: @escaping (_ userId: CKRecordID) -> Void) {
        CKContainer.default().fetchUserRecordID { (userId: CKRecordID?, error: Error?) in
            if let userId = userId {
                completion(userId)
            }
        }
    }
}
