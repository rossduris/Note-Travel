//
//  Place.swift
//  Note Travel
//
//  Created by Ross Duris on 2/16/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class Place: NSManagedObject, MKAnnotation {
    
    @NSManaged var name: String!
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var id: String!
    @NSManaged var entry: Entry?
    @NSManaged var photos: [Photo]
    
    var title : String?
    
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(latitude as Double, longitude as Double)
        }
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Place", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        name = dictionary["name"] as? String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        id = dictionary["id"] as! String
    }
    
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}