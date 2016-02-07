//
//  Entry.swift
//  Note Travel
//
//  Created by Ross Duris on 1/14/16.
//  Copyright © 2016 duris.io. All rights reserved.
//



import UIKit
import CoreData

class Entry: NSManagedObject {
    
    @NSManaged var title: String!
    
    var newEntry:Bool!
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Entry", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        title = dictionary["title"] as! String
    }
    
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}

