//
//  GoogleClient.swift
//  Note Travel
//
//  Created by Ross Duris on 2/7/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

class GoogleClient: NSObject {
    
    let API_KEY = "AIzaSyCbdkg0q6Hq7BdfRexcBCzBN2U5bbCwWcQ"
    let BASE_URL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
    let PLACE_SEARCH = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?rankby=distance"
    
    
    
    func searchForCities(searchString: String, completionHandler: (success: Bool, data:AnyObject) -> Void) {
        Alamofire.request(.GET, BASE_URL, parameters: [
            "key": API_KEY,
            "input": searchString,
            "types": "(cities)"
            ])
            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(success: true, data: JSON)
                    }
                    
                }
        }
    }
    
    func searchForNearbyPlaces(keyword: String, location: CLLocation, completionHandler: (success: Bool, data:AnyObject) -> Void) {
        Alamofire.request(.GET, PLACE_SEARCH, parameters: [
            "key": API_KEY,
            "location": "\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "keyword": keyword
            ])
            .responseJSON { response in

                
                if let JSON = response.result.value {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(success: true, data: JSON)
                    }
                    
                }
        }
    }
    
    /* Shared Instance */
    class func sharedInstance() -> GoogleClient {
        struct Singleton {
            static var sharedInstance = GoogleClient()
        }
        return Singleton.sharedInstance
    }
}