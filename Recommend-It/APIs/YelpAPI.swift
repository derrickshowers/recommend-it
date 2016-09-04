//
//  Yelp.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/5/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation
import OAuthSwift
import Alamofire

/**
    A Yelp business that may contain the following properties:
    
    :yelpId:
        The id given by the Yelp search endpoint. Used later to generate a URL
    :name:
        Name of business
    :thumbnailUrl:
        *(optional)* Url of the thumbnail image

    This is primarily used by the YelpAPI singleton to return an array of results, but
    may need to be declared in another class to understand the data being returned
    from Yelp.
*/
struct YelpBiz {
    let yelpId: String
    let name: String
    let thumbnailUrl: String?
    let city: String?
    let state: String?
}

/**
    A singleton to access Yelp's API endpoint. Proper usage is always `YelpAPI.sharedInstance().method`
    (with 'method' being the method needed to retrieve data.
*/
class YelpAPI {
    
    // MARK: - Properties
    // MARK: CONSTANTS
    private let YELP_SEARCH_URI = "https://api.yelp.com/v2/search"
    
    // MARK: Other
    private let consumerKey: String
    private let consumerSecret: String
    private let accessToken: String
    private let accessTokenSecret: String
    private let oauthClient: OAuthSwiftClient
    
    // MARK: - Singleton Pattern
    class var sharedInstance: YelpAPI {
        struct Static {
            static let instance = YelpAPI()
        }
        return Static.instance
    }
    
    // MARK: - Initializers
    init() {
        // get api keys from APIKeys.plist
        var APIKeys: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("APIKeys", ofType: "plist") {
            APIKeys = NSDictionary(contentsOfFile: path)
        } else {
            print("ERROR: APIKeys.plist does not exist")
        }
        consumerKey = APIKeys?.objectForKey("consumerKey") as! String
        consumerSecret = APIKeys?.objectForKey("consumerSecret") as! String
        accessToken = APIKeys?.objectForKey("accessToken") as! String
        accessTokenSecret = APIKeys?.objectForKey("accessTokenSecret") as! String
        
        // setup the oauth client with developer API keys
        oauthClient = OAuthSwiftClient(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret, accessToken: self.accessToken, accessTokenSecret: self.accessTokenSecret)
    }
    
    // MARK: - Private Functions
    /**
        Parses JSON returned from Yelp's API and returns a `YelpBiz` object. Pretty handy!
    
        - parameter data: The server response as NSData
    
        - returns: an array of results based on the data passed in
    */
    private func parseJSON(data: NSData) -> [YelpBiz] {
        let json: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: [])) as! NSDictionary
        var results = [YelpBiz]()
        let businesses = json.valueForKey("businesses") as! NSArray
        for biz in businesses {
            let bizId: String = biz.valueForKey("id") as! String
            let bizName: String = biz.valueForKey("name") as! String
            let bizImageUrl: String? = biz.valueForKey("image_url") as? String
            let bizLocationCity: String? = biz.valueForKeyPath("location.city") as? String
            let bizLocationState: String? = biz.valueForKeyPath("location.state_code") as? String
            let thisBiz = YelpBiz(yelpId: bizId, name: bizName, thumbnailUrl: bizImageUrl, city: bizLocationCity, state: bizLocationState)
            results.append(thisBiz)
        }
        return results
    }
    
    // MARK: - Public Functions
    /**
        Gets businesses from Yelp based on a location and search term string. Example would be 'seafood' (term)
        in 'San Francisco' (location). Because a request is being made to a server, a completion function is
        required for anything that needs to happen after the data is retrieved.
    
        - parameter location: the physical location (e.g. San Francisco)
        - parameter term: the search term (e.g. seafood)
        - parameter completion: callback function that is called once request is complete (passes in an array of businesses as `YelpBiz` objects)
    */
    func getBusinessesByLocationAndTerm(location location: String, term: String, completion: ([YelpBiz]) -> Void) {
        if location.isEmpty || term.isEmpty {
            print("location and/or term cannot be empty")
            return
        }
        let params: [String: String] = [
            "location": location,
            "term": term
        ]
        oauthClient.get(YELP_SEARCH_URI, parameters: params, success: { (data, response) -> Void in
            let businesses = self.parseJSON(data)
            completion(businesses)
        }) { (error) -> Void in
            print("there was an error: \(error)")
        }
    }
    
}