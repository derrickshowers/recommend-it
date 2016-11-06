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
    var currentRecommendation: Recommendation?

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

        guard let name = nameField.text else { return }
        guard let notes = notesTextView.text else { return }

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

        currentRecommendation = recommendationStore.createRecommendation(yelpId: selectedYelpBiz?.yelpId ?? "no-yelp-id", name: name, notes: notes, location: location, thumbnailURL: selectedYelpBiz?.thumbnailURL)

        // dismiss the view after we get the image
        self.dismiss(animated: true, completion: nil)


    }
}
