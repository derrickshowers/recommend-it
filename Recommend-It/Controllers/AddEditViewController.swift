//
//  AddEditViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/1/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {
    
    var recommendationStore: RecommendationStore?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get reservations from the AppDelegate
        recommendationStore = (UIApplication.sharedApplication().delegate as! AppDelegate).recommendationStore
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        let name = nameField.text
        let notes = notesField.text
        
        // check for empty fields - more to do here later
        if name == "" && notes == "" {
            println("name or notes not populated")
            return
        }
        
        // save the rec
        var rec = recommendationStore?.createRecommendation(yelpId: "temp-yelp-id", name: name)
        rec?.notes = notes
        
        // dismiss the view
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
