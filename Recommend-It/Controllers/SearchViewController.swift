//
//  SearchViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/1/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    // MARK: IBOutlet
    @IBOutlet weak var locationTextField: UITextField!
    
    // MARK: Other
    var results = [YelpBiz]()
    var debouncedResults: (() -> ())!
    var currentSearchText = ""
    var addEditViewController: AddEditViewController?

    // MARK: - View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make sure we're not getting results with every character typed in the search bar
        debouncedResults = debounce(NSTimeInterval(0.25), queue: dispatch_get_main_queue(), getResults)
    }

    // MARK: - CollectionView Methods
    // MARK: Datasource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        cell = self.tableView.dequeueReusableCellWithIdentifier("SearchResultCell") as! UITableViewCell
        let biz = results[indexPath.row]
        cell.textLabel?.text = biz.name
        return cell
    }
    
    // MARK: Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        addEditViewController?.selectedYelpBiz = results[indexPath.row]
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - SearchBar Methods
    // MARK: Delegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        debouncedResults()
    }
    
    // MARK: - Helper Functions
    
    /// Retrieves the location from the location text field and looks up the address using CoreLocation. Then,
    /// updates the location text field in a completion callback and gets new results.
    func setLocation() {
        let location = locationTextField.text
        let geocoder = CLGeocoder()
        var realLocation: String
        
        // get the real location
        geocoder.geocodeAddressString(location, completionHandler: { (placemarks, error) -> Void in
            if let error = error {
                println("there was an error: \(error)")
                self.locationTextField.text = ""
                return
            }
            let places = placemarks as! [CLPlacemark]
            let place = places[0]
            self.locationTextField.text = "\(place.locality), \(place.administrativeArea), \(place.country)"
            self.getResults()
        })
    }
    
    /// Retrieves the value of the location text field. Will set it to "San Francisco, CA, United States"
    /// if empty
    func getLocation() -> String {
        
        // if location is empty, let's go with San Francisco for now
        if locationTextField.text.isEmpty {
            locationTextField.text = "San Francisco, CA, United States"
        }
        
        return locationTextField.text
    }
    
    /// Retrieves the results from the Yelp API. In the callback, updates the results array and reloads
    /// the table view's data
    func getResults() {
        let location = getLocation()
        YelpAPI.sharedInstance.getBusinessesByLocationAndTerm(location: location, term: self.currentSearchText) { (businesses: [YelpBiz]) -> Void in
            self.results = businesses
            self.tableView.reloadData()
        }
    }
    
    // MARK: - IBAction Functions

    @IBAction func changeButtonPressed(sender: AnyObject) {
        setLocation()
    }

}
