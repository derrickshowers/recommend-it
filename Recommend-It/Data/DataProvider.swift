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

    // MARK: - Public Interface

    func fetchData(privateDB: Bool, forCurrentUser: Bool, completion: @escaping (_ models: [T]) -> Void) {

        if forCurrentUser {
            // TOOD: Store userId so we don't have to make a separate request everytime
            retrieveUserRecordId() { (userId: CKRecordID) in
                let reference = CKReference(recordID: userId, action: .none)
                let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
                let query = CKQuery(recordType: T.className, predicate: predicate)
                self.performDatabaseQuery(database: self.getDatabase(privateDB: privateDB), query: query, completion: completion)
            }
        } else {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: T.className, predicate: predicate)
            performDatabaseQuery(database: self.getDatabase(privateDB: privateDB), query: query, completion: completion)
        }

    }

    func fetchSingleRecord(recordId: CKRecordID, privateDB: Bool, completion: @escaping (_ model: T) -> Void) {

        getDatabase(privateDB: privateDB).fetch(withRecordID: recordId) { (record: CKRecord?, error: Error?) in

            guard let record = record,
                let model = T.buildModelFromRecord(record) as? T else {
                return
            }

            DispatchQueue.main.async() {
                completion(model)
            }
        }
    }

    func deleteRecord(recordId: CKRecordID, privateDB: Bool, completion: @escaping (_ recordId: CKRecordID?) -> Void) {

        getDatabase(privateDB: privateDB).delete(withRecordID: recordId) { (recordId: CKRecordID?, error: Error?) in
            guard let recordId = recordId else {
                return
            }

            DispatchQueue.main.async() {
                completion(recordId)
            }
        }
    }

    func saveData(model: T, privateDB: Bool, completion: @escaping (_ savedRecord: CKRecord) -> Void) {

        guard let record = T.buildRecordFromModel(model) else {
            return
        }

        getDatabase(privateDB: privateDB).save(record) { (savedRecord: CKRecord?, error: Error?) in

            guard let savedRecord = savedRecord else {
                return
            }

            DispatchQueue.main.async() {
                completion(savedRecord)
            }
        }
    }

    // MARK - Private helpers

    private func performDatabaseQuery(database: CKDatabase, query: CKQuery, completion: @escaping (_ models: [T]) -> Void) {
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
                completion(models)
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

    private func getDatabase(privateDB: Bool) -> CKDatabase {

        let container = CKContainer.default()
        return privateDB ? container.privateCloudDatabase : container.publicCloudDatabase
    }
}
