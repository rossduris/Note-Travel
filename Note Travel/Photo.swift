//
//  Photo.swift
//  Note Travel
//
//  Created by Ross Duris on 2/16/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    
    @NSManaged var imagePath: String
    @NSManaged var imageUrlString: String
    @NSManaged var entry: Entry?
    @NSManaged var place: Place?
    
    
    var isDownloading = false
    
    
    /*
    Core Data Convenience
    */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        imagePath = dictionary["imagePath"] as! String
        imageUrlString = dictionary["imageUrlString"] as! String
        
    }
    
    func downloadImage() {
        self.isDownloading = true

        if self.imageUrlString != "" {
            if let imageURL = NSURL(string: self.imageUrlString) {
                if let imageData = NSData(contentsOfURL: imageURL) {
                    let image = UIImage(data: imageData)
                    self.image = image!
                    FoursquareClient.Caches.imageCache.storeImage(image, withIdentifier: self.imagePath)
                    self.isDownloading = false
                    print("photo loaded")
                    self.image = image
                    NSNotificationCenter.defaultCenter().postNotificationName("ImageLoadedNotification", object: self)
                    
                        self.saveContext()
                }
            } else {
                print("no photo URL")
            }
        }
    }
    
    
   
    override func prepareForDeletion() {
        //Delete underlying image file automatically
        deleteImage(self.imagePath)
    }
    
    
    func deleteImage(path: String){
        print("deleting image")
        FoursquareClient.Caches.imageCache.removeImage(path)
    }
    
    
    var image: UIImage? {
        get {
            return FoursquareClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            FoursquareClient.Caches.imageCache.storeImage(image, withIdentifier: imagePath)
        }
    }
    
    
}

