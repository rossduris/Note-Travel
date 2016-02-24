//
//  FoursquareClient.swift
//  Note Travel
//
//  Created by Ross Duris on 2/15/16.
//  Copyright © 2016 duris.io. All rights reserved.
//


import Alamofire
import CoreData

class FoursquareClient: NSObject {

    let CLIENT_ID = "GDSREAWQSSHEYW2KG5S3ZGG0O5WM5AGDQ0MLEXT20WLUJAQH"
    let CLIENT_SECRET = "JRCZCASUNKFWB2MXUNIJMDDCHPGREIO0FQ2DENQXWA3U1EDR"
    let BASE_URL = "https://api.foursquare.com/v2/venues/"
    let VERSION = "20130815"
    
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    /*
    Core Data Convenience
    */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var scratchContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        context.persistentStoreCoordinator =  CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        return context
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    

    func searchFoursquareForPlace(query: String, latitude: Double, longitude: Double, completionHandler: (success:Bool, places:[Place], error:String?) -> Void) {
        
        let parameters = [
            "query":query,
            "ll":"\(latitude),\(longitude)",
            "client_id": CLIENT_ID,
            "v": VERSION,
            "client_secret": CLIENT_SECRET
        ]
        
        let method = "search"
        var tempResultsArray = [Place]()
        
        Alamofire.request(.GET, BASE_URL + method, parameters: parameters)
            .responseJSON { response in
                if response.result.error != nil {
                    let error = response.result.error!.localizedDescription
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success: false, places:[], error: error)
                    })
                } else {
                    if let JSON = response.result.value {
                        if let response = JSON["response"] as? [String: AnyObject]  {
                            if let venues = response["venues"] {
                                for venue in (venues as? NSArray)! {
                                    if let location = venue["location"] {
                                        if let lat = location!["lat"], let lng = location!["lng"] {
                                            if let name = venue["name"] {
                                                
                                                let title = name as! String
                                                let latitude = lat as! Double
                                                let longitude = lng as! Double
                                                
                                                if let id = venue["id"] as? String {
                                                    let dictionary = [
                                                        "name": title,
                                                        "latitude": latitude,
                                                        "longitude": longitude,
                                                        "rating": 0,
                                                        "id":id
                                                        ] as [String: AnyObject]
                                                    print(id)
                                                    let place = Place(dictionary: dictionary, context: self.scratchContext)
                                                    
                                                    place.title = title
                                                    tempResultsArray.append(place)
                                                }
                                            }
                                        }
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), {
                                    completionHandler(success: true, places: tempResultsArray, error: nil)
                                })
                            }
                        }
                    }
                }
            }
        }
    
    
    
    
    
    func downloadPhotos(venueId: String, entry: Entry, place: Place, completionHandler: (success:
        Bool, photos:[Photo], error:String?) -> Void) {
        
        let parameters = [
            "client_id": CLIENT_ID,
            "v": VERSION,
            "client_secret": CLIENT_SECRET
        ]
        
        let method = "\(venueId)/photos"
        
        Alamofire.request(.GET, BASE_URL + method, parameters: parameters)
            .responseJSON { response in
                if response.result.error != nil {
                    let error = response.result.error!.localizedDescription
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success: false, photos: [], error: error)
                    })
                } else {
                    if let JSON = response.result.value {
                        if let response = JSON["response"] as? [String: AnyObject] {
                            if let photos = response["photos"] as? [String: AnyObject]{
                                
                                if let items = photos["items"] as? NSArray {
                                    if items.count == 0 {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            completionHandler(success: false, photos: [], error: "No photos found")
                                        })
                                    }
                                    for item in items {
                                        
                                        if let prefix = item["prefix"], let suffix = item["suffix"] {
                                            let size = "300x500"
                                            let imageUrl = "\(prefix!)\(size)\(suffix!)"
                                            
                                            let uuid = NSUUID().UUIDString
                                            let dictionary = [
                                                "imagePath": "image_\(uuid)",
                                                "imageUrlString": imageUrl
                                            ]
                                            let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                                            photo.entry = entry
                                            photo.place = place
                                            photo.downloadImage()
                                            self.saveContext()
                                            
                                            var downloadedPhotos = [Photo]()
                                            downloadedPhotos.append(photo)
                                            dispatch_async(dispatch_get_main_queue(), {
                                                completionHandler(success: true, photos: downloadedPhotos, error: nil)
                                            })
                                        }
                                    }
                                }
                            }
                        }

                    }
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