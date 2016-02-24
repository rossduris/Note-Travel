//
//  FoursquareClient.swift
//  Note Travel
//
//  Created by Ross Duris on 2/15/16.
//  Copyright © 2016 duris.io. All rights reserved.
//


import Alamofire

class FoursquareClient: NSObject {

    let CLIENT_ID = "GDSREAWQSSHEYW2KG5S3ZGG0O5WM5AGDQ0MLEXT20WLUJAQH"
    let CLIENT_SECRET = "JRCZCASUNKFWB2MXUNIJMDDCHPGREIO0FQ2DENQXWA3U1EDR"
    let BASE_URL = "https://api.foursquare.com/v2/venues/"
    let VERSION = "20130815"
    
    
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    

    func searchFoursquareForPlace(query: String, latitude: Double, longitude: Double, completionHandler: (success:Bool, data:AnyObject) -> Void) {
        
        let parameters = [
            "query":query,
            "ll":"\(latitude),\(longitude)",
            "client_id": CLIENT_ID,
            "v": VERSION,
            "client_secret": CLIENT_SECRET
        ]
        
        let method = "search"
        
        
        Alamofire.request(.GET, BASE_URL + method, parameters: parameters)
            .responseJSON { response in
                
                if let JSON = response.result.value {                    
                        completionHandler(success: true, data: JSON)
                }
        }
        
    }
    
    func searchFoursquareForPlacePhotos(venueId: String, completionHandler: (success:Bool, data:AnyObject) -> Void) {
        
        let parameters = [
            "client_id": CLIENT_ID,
            "v": VERSION,
            "client_secret": CLIENT_SECRET
        ]
        
        let method = "\(venueId)/photos"
        
        
        Alamofire.request(.GET, BASE_URL + method, parameters: parameters)
            .responseJSON { response in
                
                if let JSON = response.result.value {
                    
                        completionHandler(success: true, data: JSON)
                    }
                
        }
        
    }
    
    /* Shared Instance */
    class func sharedInstance() -> FoursquareClient {
        struct Singleton {
            static var sharedInstance = FoursquareClient()
        }
        return Singleton.sharedInstance
    }

}

