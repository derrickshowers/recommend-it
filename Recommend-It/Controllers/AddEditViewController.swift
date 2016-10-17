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
    @IBOutlet weak var notesField: UITextField!

    // MARK: Other
    var recommendationStore: RecommendationStore?
    var selectedYelpBiz: YelpBiz?
    var currentRecommendation: Recommendation?

    // MARK: - View Controller Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // get reservations from the AppDelegate
        recommendationStore = (UIApplication.shared.delegate as! AppDelegate).recommendationStore

        // show the blue version of nav controller
        navigationController?.navigationBar.makeDefaultBlue()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let selectedYelpBiz = selectedYelpBiz {
            nameField.text = selectedYelpBiz.name
        }
        if let currentRecommendation = currentRecommendation {
            nameField.text = currentRecommendation.name
            notesField.text = currentRecommendation.notes
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
        let name = nameField.text
        let notes = notesField.text
        var rec: Recommendation

        // check for empty fields - more to do here later
        if name == "" && notes == "" {
            print("name or notes not populated")
            return
        }

        // save the rec
        if let currentRecommendation = currentRecommendation {
            rec = currentRecommendation
            rec.name = nameField.text!
        } else {
            rec = recommendationStore!.createRecommendation(yelpId: selectedYelpBiz?.yelpId ?? "no-yelp-id", name: name!)
        }
        rec.notes = notes

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
        rec.location = location

        // save the image
        if let selectedYelpBiz = selectedYelpBiz, let selectedYelpBizImg = selectedYelpBiz.thumbnailUrl {
            Alamofire.request(selectedYelpBizImg, method: .get).response { response in

                rec.thumbnail = response.data! as Data

                // dismiss the view after we get the image
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            // no image? just dismiss the view
            let placeholderImage = UIImage(named: "RecImagePlaceholder")
            rec.thumbnail = UIImagePNGRepresentation(placeholderImage!)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
