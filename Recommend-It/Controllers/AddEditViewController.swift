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
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    
    var recommendationStore: RecommendationStore?
    var selectedYelpBiz: YelpBiz?
    var currentRecommendation: Recommendation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get reservations from the AppDelegate
        recommendationStore = (UIApplication.sharedApplication().delegate as! AppDelegate).recommendationStore
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
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
