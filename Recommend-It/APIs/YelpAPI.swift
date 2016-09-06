//
//  Yelp.swift
//  Recommend-It
//
//  Created by Derrick Showers on 6/5/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import Foundation
import Alamofire

/**
 A Yelp business that may contain the following properties:

 :yelpId: The id given by the Yelp search endpoint. Used later to generate a URL
 :name: Name of business
 :thumbnailUrl: *(optional)* Url of the thumbnail image

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
    private let YELP_SEARCH_URI = "https://api.yelp.com/v3/businesses/search"
    private let YELP_AUTH_URI = "https://api.yelp.com/oauth2/token"

    // MARK: Other
    private let clientId: String
    private let clientSecret: String
    private var accessToken: String?

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
        clientId = APIKeys?.objectForKey("clientId") as! String
        clientSecret = APIKeys?.objectForKey("clientSecret") as! String
    }

    // MARK: - Private Functions
    /**
     Parses JSON returned from Yelp's API and returns a `YelpBiz` object. Pretty handy!

     - parameter data: The server response as NSData

     - returns: an array of results based on the data passed in
     */
    private func parseJSON(data: NSDictionary) -> [YelpBiz] {
        var results = [YelpBiz]()
        let businesses = data.valueForKey("businesses") as! NSArray
        for biz in businesses {
            let bizId: String = biz.valueForKey("id") as! String
            let bizName: String = biz.valueForKey("name") as! String
            var bizImageUrl: String? = biz.valueForKey("image_url") as? String
            let bizLocationCity: String? = biz.valueForKeyPath("location.city") as? String
            let bizLocationState: String? = biz.valueForKeyPath("location.state_code") as? String

            // Image url needs to be https
            if let imageUrl = bizImageUrl {
                bizImageUrl = imageUrl.stringByReplacingOccurrencesOfString("http", withString: "https", options: NSStringCompareOptions.LiteralSearch, range: nil)
            }

            let thisBiz = YelpBiz(yelpId: bizId, name: bizName, thumbnailUrl: bizImageUrl, city: bizLocationCity, state: bizLocationState)

            results.append(thisBiz)
        }

        return results
    }
    
    /**
     Gets the access token from Yelp and stores it in a private var

     - parameter completion: callback function that is called once accessToken is available
     */
    private func getAccessToken(completion: (String) -> ()) {
        if let accessToken = accessToken {
            completion(accessToken)
        }

        let params = [
            "grant_type": "client_credentials",
            "client_id": clientId,
            "client_secret": clientSecret
        ]

        Alamofire.request(.POST, YELP_AUTH_URI, parameters: params).responseJSON { response in
            if let data = response.result.value as? NSDictionary {
                self.accessToken = data.objectForKey("access_token") as? String
                completion(self.accessToken!)
            }
        }
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
    func getBusinessesByLocationAndTerm(location location: String?, term: String?, completion: ([YelpBiz]) -> Void) {
        guard let location = location else {
            return
        }

        guard let term = term else {
            return
        }

        let params: [String: String] = [
            "location": location,
            "term": term
        ]

        getAccessToken { accessToken in
            let headers = [
                "Authorization": "Bearer \(accessToken)"
            ]
            Alamofire.request(.GET, self.YELP_SEARCH_URI, parameters: params, headers: headers).responseJSON { response in
                switch response.result {
                case .Success(let data):
                    let businesses = self.parseJSON(data as! NSDictionary)
                    completion(businesses)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
};