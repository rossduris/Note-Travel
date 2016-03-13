//
//  GoogleClient.swift
//  Note Travel
//
//  Created by Ross Duris on 2/7/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import Alamofire

class GoogleClient: NSObject {
    
    let API_KEY = "AIzaSyCbdkg0q6Hq7BdfRexcBCzBN2U5bbCwWcQ"
    let BASE_URL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
    
    
    func searchForCities(searchString: String, completionHandler: (success: Bool, results:[String], error: String?) -> Void) {

        
        Alamofire.request(.GET, BASE_URL, parameters: [
            "key": API_KEY,
            "input": searchString,
            "types": "(cities)"
            ])
            .responseJSON { response in
                print(response)
                if response.result.error != nil {
                    let error = response.result.error!.localizedDescription
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success: false, results: [], error: error)
                    })
                }else {
                    
                    if let JSON = response.result.value {
                        if JSON["error_message"] as? String != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                completionHandler(success: false, results: [], error: "There seems to be an error with the server.")
                            })
                        }
                    if let predictions = JSON["predictions"]{
                        var resultStrings = [String]()
                        for prediction in (predictions as? NSArray)!{
                            print(prediction["description"]!!)
                            let string = prediction["description"]!!
                            resultStrings.append(string as! String)
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            //let JSON["error_message"]
                            completionHandler(success: true, results: resultStrings, error: nil)
                        })
                    }
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