//
//  AddEditViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/1/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit
import Alamofire

class AddEditViewController: UIViewController {

    // MARK: - Properties
    // MARK: IBOutlet
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!

    // MARK: Other
    var recommendationStore: RecommendationStore!
    var selectedYelpBiz: YelpBiz?
    var currentRecommendation: OldRecommendation?

    // MARK: - View Controller Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // get reservations from the AppDelegate
        recommendationStore = RecommendationStore.sharedInstance

        // show the blue version of nav controller
        navigationController?.navigationBar.makeDefaultBlue()

        notesTextView.contentInset = UIEdgeInsetsMake(-5, -5, 0, 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        if let selectedYelpBiz = selectedYelpBiz {
            nameField.text = selectedYelpBiz.name
        }
        if let currentRecommendation = currentRecommendation {
            nameField.text = currentRecommendation.name
            notesTextView.text = currentRecommendation.notes
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let svc = segue.destination as! SearchViewController
        svc.addEditViewController = self
    }

    // MARK: - IBAction Functions

    @IBAction func cancelPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: AnyObject) {

        guard let name = nameField.text,
            let notes = notesTextView.text,
            let yelpId = selectedYelpBiz?.yelpId else {
            return
        }

        // save the location
        var location = ""

        if let city = selectedYelpBiz?.city {
            location = "\(city)"
        }

        if let state = selectedYelpBiz?.state {
            if !location.isEmpty {
                location = "\(location), \(state)"
            } else {
                location = "\(state)"
            }
        }

        let recommendation = Recommendation(yelpId: yelpId, name: name, notes: notes, location: location, thumbnailURL: selectedYelpBiz?.thumbnailURL)

        DataProvider<Recommendation>().saveData(model: recommendation, privateDB: false) { (savedRecommendation: Recommendation) in
            NotificationCenter.default.post(name: Notification.Name("newRecommendationSaved"), object: nil, userInfo: ["recommendation": savedRecommendation])
            self.dismiss(animated: true, completion: nil)
        }

    }
}
