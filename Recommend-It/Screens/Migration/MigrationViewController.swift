//
//  MigrationViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 1/22/17.
//  Copyright © 2017 Derrick Showers. All rights reserved.
//

import Foundation
import UIKit

class MigrationViewController: UIViewController {

    enum UserDefaultsKey {
        static let messageShown = "migrationMessageShown"
    }

    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var migrationLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.set(true, forKey: UserDefaultsKey.messageShown)
    }

    // MARK: - Private helpers

    private func migrateOldRecommendations() {
        let recommendations = RecommendationStore.sharedInstance.allRecommendations
        let recommendationDataProvider = DataProvider<Recommendation>()

        if recommendations.count == 0 {
            self.dismiss(animated: true, completion: nil)
        } else {
            confirmationButton.isHidden = true
            migrationLabel.isHidden = false
        }

        recommendations.forEach { (oldRecommendation: OldRecommendation) in

            guard let yelpId = oldRecommendation.yelpId,
                let name = oldRecommendation.name else {
                self.dismiss(animated: true, completion: nil)
                return
            }

            let recommendation = Recommendation(yelpId: yelpId, name: name, notes: oldRecommendation.notes, location: oldRecommendation.location, thumbnailURL: oldRecommendation.thumbnailURL)

            recommendationDataProvider.saveData(model: recommendation, privateDB: false, completion: { (savedRecommendation: Recommendation) in
                self.dismiss(animated: true, completion: nil)
            })
        }
    }

    private func onTapConfirmationButton(_ sender: UIButton) {
        migrateOldRecommendations()
    }

    @IBAction func didTapConfirmationButton(_ sender: UIButton) {
        onTapConfirmationButton(sender)
    }
}
