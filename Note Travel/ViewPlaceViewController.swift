//
//  ViewPlaceViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 2/15/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewPlaceViewController: UIViewController, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var saveButton:UIButton!
    @IBOutlet weak var topImageView:UIImageView!
    @IBOutlet weak var photoCountLabel:UILabel!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    var images = [UIImage]()
    
    //var selectedPlace = MKPointAnnotation()

    //var entry : Entry!
    
    var place: Place!

    
    
    
    /*
    Core Data Convenience
    */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPhotos()
        
        if place.photos.isEmpty {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
        }
        
        fetchedPhotosController.delegate = self
        
        //Notification observer for when an image is downloaded
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoadImage:", name: "ImageLoadedNotification", object: nil)

        title = place.name
        let id = place.id
        //print(place.id)
 
        if place.photos.isEmpty {
            FoursquareClient.sharedInstance().searchFoursquareForPlacePhotos(id!) { (success:Bool, data: AnyObject) in
                if success {
                    if let response = data["response"] as? [String: AnyObject] {
                        if let photos = response["photos"] as? [String: AnyObject]{
                            if let items = photos["items"] as? NSArray {
                                for item in items {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        print(items.count)
                                        if let prefix = item["prefix"], let suffix = item["suffix"] {
                                            let size = "300x500"
                                            let imageUrl = "\(prefix!)\(size)\(suffix!)"
                                            print(imageUrl)
                                            
                                            
                                            let uuid = NSUUID().UUIDString
                                            let dictionary = [
                                                "imagePath": "image_\(uuid)",
                                                "imageUrlString": imageUrl
                                            ]
                                            let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                                            
                                            photo.place = self.place
                                            photo.downloadImage()
                                            
                                            
                                        }
                                    })
                                    
                                }
                                
                            }
                        }
                    }
                    
                }
            }
        } else  {
            let photo = self.fetchedPhotosController.fetchedObjects?.first as! Photo
            self.topImageView.image = photo.image
        }
        
    }
    
    /*
    Image Loaded Notification
    */
    func didLoadImage(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            print("ImageLoadedNotification")
            let photo = self.fetchedPhotosController.fetchedObjects?.first as! Photo
            self.topImageView.image = photo.image
            self.photoCountLabel.text = "\(self.fetchedPhotosController.fetchedObjects?.count)"
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        })
        
    }
    
    
    func didLoadImage() {
        topImageView.image = images.first
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    /*
    Try to fetch the photos from Core Data
    */
    lazy var fetchedPhotosController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "place == %@", self.place)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        
        return fetchedResultsController
    }()
    
    func fetchPhotos() {
        var error: NSError?
        do {
            try fetchedPhotosController.performFetch()
            print("do")
            
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
    }
    
    

    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                print("insert")
                print(fetchedPhotosController.fetchedObjects?.count)
                
            case .Delete:
                print("delete")
                print(fetchedPhotosController.fetchedObjects?.count)
            default:
                return
            }
    }
  
    
    

    
    
    @IBAction func didTouchSaveButton() {
        print(place.title)
        print(place.entry?.title)
        saveContext()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

}
