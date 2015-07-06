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
        recommendationStore = (UIApplication.sharedApplication().delegate as! AppDelegate).recommendationStore

        // show the blue version of nav controller
        navigationController?.navigationBar.makeDefaultBlue()
    }

    override func viewWillAppear(animated: Bool) {
        if let selectedYelpBiz = selectedYelpBiz {
            nameField.text = selectedYelpBiz.name
        }
        if let currentRecommendation = currentRecommendation {
            nameField.text = currentRecommendation.name
            notesField.text = currentRecommendation.notes
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let svc = segue.destinationViewController as! SearchViewController
        svc.addEditViewController = self
    }

    // MARK: - IBAction Functions

    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func savePressed(sender: AnyObject) {
        let name = nameField.text
        let notes = notesField.text
        var rec: Recommendation
        
        // check for empty fields - more to do here later
        if name == "" && notes == "" {
            println("name or notes not populated")
            return
        }
        
        // save the rec
        if let currentRecommendation = currentRecommendation {
            rec = currentRecommendation
            rec.name = nameField.text
        } else {
            rec = recommendationStore!.createRecommendation(yelpId: selectedYelpBiz?.yelpId ?? "no-yelp-id", name: name)
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
        if let selectedYelpBiz = selectedYelpBiz, selectedYelpBizImg = selectedYelpBiz.thumbnailUrl {
            Alamofire.request(.GET, selectedYelpBizImg).response() {
                (req, res, data, error) in
                
                if let data = data as? NSData {
                    rec.thumbnail = data
                }
                
                // dismiss the view after we get the image
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            // no image? just dismiss the view
            var placeholderImage = UIImage(named: "RecImagePlaceholder")
            rec.thumbnail = UIImagePNGRepresentation(placeholderImage)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
