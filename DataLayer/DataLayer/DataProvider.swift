//
//  DataProvider.swift
//  Recommend-It
//
//  Created by Derrick Showers on 1/21/17.
//  Copyright © 2017 Derrick Showers. All rights reserved.
//

import Foundation
import CloudKit

public protocol DataProviderErrorDelegate {
    func dataProviderDidError(error: Error?) -> Void
}

public protocol Model {
    var className: String { get }
    static var className: String { get }
    static func buildModelFromRecord(_ record: CKRecord) -> Model?
    static func buildRecordFromModel(_ model: Model) -> CKRecord?
}

public class DataProvider<T: Model> {

    public var errorDelegate: DataProviderErrorDelegate?

    // MARK: - Public Interface

    public init() {}

    public func fetchData(privateDB: Bool, forCurrentUser: Bool, completion: @escaping (_ models: [T]) -> Void) {

        if forCurrentUser {
            // TOOD: Store userId so we don't have to make a separate request everytime
            retrieveUserRecordId() { (userId: CKRecordID?) in

                // TODO: Better error handling - just passing back 0 records if user doesn't exist
                guard let userId = userId else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }

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

    public func fetchSingleRecord(recordId: CKRecordID, privateDB: Bool, completion: @escaping (_ model: T) -> Void) {

        getDatabase(privateDB: privateDB).fetch(withRecordID: recordId) { (record: CKRecord?, error: Error?) in

            guard let record = record,
                let model = T.buildModelFromRecord(record) as? T else {
                    self.handleError(error)
                    return
            }

            DispatchQueue.main.async {
                completion(model)
            }
        }
    }

    public func deleteRecord(recordId: CKRecordID, privateDB: Bool, completion: ((_ recordId: CKRecordID?) -> Void)? = nil) {

        getDatabase(privateDB: privateDB).delete(withRecordID: recordId) { (recordId: CKRecordID?, error: Error?) in
            guard let recordId = recordId else {
                self.handleError(error)
                return
            }

            DispatchQueue.main.async {
                completion?(recordId)
            }
        }
    }

    public func saveData(model: T, privateDB: Bool, completion: @escaping (_ model: T) -> Void) {

        guard let record = T.buildRecordFromModel(model) else {
            return
        }

        getDatabase(privateDB: privateDB).save(record) { (savedRecord: CKRecord?, error: Error?) in

            guard let savedRecord = savedRecord,
                let model = T.buildModelFromRecord(savedRecord) as? T else {
                    self.handleError(error)
                    return
            }

            DispatchQueue.main.async {
                completion(model)
            }
        }
    }

    // MARK - Private helpers

    private func performDatabaseQuery(database: CKDatabase, query: CKQuery, completion: @escaping (_ models: [T]) -> Void) {

        database.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
            guard error == nil else {
                self.handleError(error)
                return
            }

            var models = [T]()

            results?.forEach({ (record: CKRecord) in

                guard let model = T.buildModelFromRecord(record) as? T else {
                    return
                }

                models.append(model)
            })

            DispatchQueue.main.async {
                completion(models)
            }
        }
    }

    private func retrieveUserRecordId(completion: @escaping (_ userId: CKRecordID?) -> Void) {

        CKContainer.default().fetchUserRecordID { (userId: CKRecordID?, error: Error?) in
            completion(userId)
        }
    }

    private func getDatabase(privateDB: Bool) -> CKDatabase {

        let container = CKContainer.default()
        return privateDB ? container.privateCloudDatabase : container.publicCloudDatabase
    }

    private func handleError(_ error: Error?) {

        DispatchQueue.main.async {
            self.errorDelegate?.dataProviderDidError(error: error)
        }
    }
}
