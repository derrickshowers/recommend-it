//
//  SearchViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/1/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

    // MARK: - Properties
    // MARK: IBOutlet
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locationSearchBar: UISearchBar!

    // MARK: Other
    var results = [YelpBiz]()
    var debouncedResults: (() -> ())!
    var currentSearchText: String?
    var addEditViewController: AddEditViewController?
    let locationManager = CLLocationManager()

    // MARK: - View Controller Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // change UISearchBar text color
        locationSearchBar.textColor(UIColor.whiteColor())

        // setup the location manager to get user's current location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            locationTextField.text = "San Francisco, CA, United States"
        }

        // make sure we're not getting results with every character typed in the search bar
        debouncedResults = debounce(NSTimeInterval(0.25), queue: dispatch_get_main_queue(), action: getResults)
    }

    override func viewDidDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - TableView Methods
    // MARK: Datasource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        cell = self.tableView.dequeueReusableCellWithIdentifier("SearchResultCell")! as UITableViewCell
        let biz = results[indexPath.row]
        cell.textLabel?.text = biz.name

        // let's make the text look a little prettier
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)

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

    // MARK: - TextField Methods
    // MARK: Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        setLocation()
        textField.resignFirstResponder()
        return true
    }

    // MARK: - CLLocationManager Methods
    // MARK: Delegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            if error == nil {
                if placemarks!.count > 0 {
                    let locality = (placemarks![0] as CLPlacemark).locality
                    self.locationTextField.text = locality
                    self.setLocation()
                    self.locationManager.stopUpdatingLocation()
                }
            } else {
                print(error)
            }
        })
    }

    // MARK: - Helper Functions

    /// Retrieves the location from the location text field and looks up the address using CoreLocation. Then,
    /// updates the location text field in a completion callback and gets new results.
    func setLocation() {
        let location = locationTextField.text
        let geocoder = CLGeocoder()
        var _: String

        // get the real location
        if let location = location {
            geocoder.geocodeAddressString(location, completionHandler: { (placemarks, error) -> Void in
                if let error = error {
                    print("there was an error: \(error)")
                    self.locationTextField.text = ""
                    return
                }
                let places = placemarks as [CLPlacemark]!
                let place = places[0]
                self.locationTextField.text = "\(place.locality!), \(place.administrativeArea!), \(place.country!)"
                self.getResults()
            })
        }
    }

    /// Retrieves the results from the Yelp API. In the callback, updates the results array and reloads
    /// the table view's data
    func getResults() {
        let location = locationTextField.text
        YelpAPI.sharedInstance.getBusinessesByLocationAndTerm(location: location, term: self.currentSearchText) { (businesses: [YelpBiz]) -> Void in
            self.results = businesses
            self.tableView.reloadData()
        }
    }

    // MARK: - IBAction Functions

    @IBAction func changeButtonPressed(sender: AnyObject) {
        locationTextField.becomeFirstResponder()
    }
}
