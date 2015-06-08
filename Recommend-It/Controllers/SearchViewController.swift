//
//  SearchViewController.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/1/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    var results = [YelpBiz]()
    var debouncedResults: (() -> ())!
    var currentSearchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        debouncedResults = debounce(NSTimeInterval(0.25), queue: dispatch_get_main_queue(), getResults)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SearchResultCell") as! UITableViewCell
        let biz = results[indexPath.row]
        cell.textLabel?.text = biz.name
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        debouncedResults()
    }
    
    func getResults() {
        YelpAPI.sharedInstance.getBusinessesByLocationAndTerm(location: "San+Francisco", term: self.currentSearchText) { (businesses: [YelpBiz]) -> Void in
            self.results = businesses
        }
    }
    
//    func getLocation() {
//        var geocoder = CLGeocoder()
//        geocoder.geocodeAddressString("Mountain Veiw", completionHandler: { (placemarks, error) -> Void in
//            let places = placemarks as NSArray
//            for place in places {
//                let clPlace = place as! CLPlacemark
//                println("Your location is \(clPlace.locality) in \(clPlace.administrativeArea) in \(clPlace.country)")
//            }
//        })
//    }

}
