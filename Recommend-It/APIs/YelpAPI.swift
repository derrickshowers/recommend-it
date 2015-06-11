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

struct YelpBiz {
    let yelpId: String
    let name: String
    let thumbnailUrl: String?
}

class YelpAPI {
    
    // CONSTANTS
    private let YELP_SEARCH_URI = "http://api.yelp.com/v2/search"
    
    private let consumerKey: String
    private let consumerSecret: String
    private let accessToken: String
    private let accessTokenSecret: String
    private let oauthClient: OAuthSwiftClient
    
    // singleton pattern
    class var sharedInstance: YelpAPI {
        struct Static {
            static let instance = YelpAPI()
        }
        return Static.instance
    }
    
    init() {
        // get api keys from APIKeys.plist
        var APIKeys: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("APIKeys", ofType: "plist") {
            APIKeys = NSDictionary(contentsOfFile: path)
        } else {
            println("ERROR: APIKeys.plist does not exist")
        }
        consumerKey = APIKeys?.objectForKey("consumerKey") as! String
        consumerSecret = APIKeys?.objectForKey("consumerSecret") as! String
        accessToken = APIKeys?.objectForKey("accessToken") as! String
        accessTokenSecret = APIKeys?.objectForKey("accessTokenSecret") as! String
        
        // setup the oauth client with developer API keys
        oauthClient = OAuthSwiftClient(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret, accessToken: self.accessToken, accessTokenSecret: self.accessTokenSecret)
    }
    
    private func parseJSON(data: NSData) -> [YelpBiz] {
        let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary
        var results = [YelpBiz]()
        let businesses = json.valueForKey("businesses") as! NSArray
        for biz in businesses {
            let bizId: String = biz.valueForKey("id") as! String
            let bizName: String = biz.valueForKey("name") as! String
            let bizImageUrl: String? = biz.valueForKey("image_url") as? String
            let thisBiz = YelpBiz(yelpId: bizId, name: bizName, thumbnailUrl: bizImageUrl)
            results.append(thisBiz)
        }
        return results
    }
    
    func getBusinessesByLocationAndTerm(#location: String, term: String, completion: ([YelpBiz]) -> Void) {
        if location.isEmpty || term.isEmpty {
            println("location and/or term cannot be empty")
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
            println("there was an error: \(error)")
        }
    }
    
}