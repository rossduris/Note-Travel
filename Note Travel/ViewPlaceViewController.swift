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
    @IBOutlet weak var ratingSlider:UIView!
    @IBOutlet weak var subLabel:UILabel!
    @IBOutlet weak var tempLabel:UILabel!
    @IBOutlet weak var photoTipLabel:UILabel!
    @IBOutlet weak var errorLabel:UILabel!
    @IBOutlet weak var savedRatingLabel:UILabel!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var editButton:UIBarButtonItem!
    
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
        
        let slider = self.ratingSlider as! RatingSlider
        
        if place.rating != 0 {
            print(place.rating)
            slider.hidden = true

            savedRatingLabel.textColor = calulateColor(place.rating)
            savedRatingLabel.text = "\(place.rating)/10"
            savedRatingLabel.hidden = false
            tempLabel.hidden = true
            subLabel.text = "You Voted"
            saveButton.hidden = true
            editButton.title = "Edit"
        } else {
            editButton.title = ""
            savedRatingLabel.hidden = true
            self.navigationItem.backBarButtonItem?.enabled = false
            subLabel.text = place.name + "?"

        }
                    photoTipLabel.hidden = true
        
        savedRatingLabel.textColor = calulateColor(place.rating)
        
        if place.photos.isEmpty {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
        }
        
    
        
        let photoButton = UIButton()
        photoButton.frame = topImageView.frame
        photoButton.addTarget(self, action: "loadRandomPhoto", forControlEvents: .TouchUpInside)
        view.addSubview(photoButton)
        
        fetchedPhotosController.delegate = self
        
        //Notification observer for when an image is downloaded
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoadImage:", name: "ImageLoadedNotification", object: nil)

        title = place.name
        let id = place.id
 
        if place.photos.isEmpty {
            FoursquareClient.sharedInstance().searchFoursquareForPlacePhotos(id!) { (success:Bool, data: AnyObject) in
                if success {
                    if let response = data["response"] as? [String: AnyObject] {
                        if let photos = response["photos"] as? [String: AnyObject]{
                            if let items = photos["items"] as? NSArray {
                                for item in items {

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
                                            photo.entry = self.place.entry
                                            photo.place = self.place
                                            photo.downloadImage()
                                            
                                            
                                        }
                                    
                                    
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
 
    
    
    override func viewWillDisappear(animated: Bool) {
        if place.rating == 0 {
            sharedContext.deleteObject(place)
        }
    }
    
    func loadRandomPhoto(){
        hidePhotoTip()
        let photoCount = place.photos.count
        let randomPhoto = Int(arc4random_uniform(UInt32(photoCount)))
        UIView.animateWithDuration(1, animations: { () -> Void in
            
            self.topImageView.alpha = 0.5
            self.topImageView.image = self.place.photos[randomPhoto].image
            self.topImageView.alpha = 1

        })
    }
    
    /*
    Image Loaded Notification
    */
    func didLoadImage(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            print("ImageLoadedNotification")
            self.photoTipLabel.hidden = false
            let photo = self.fetchedPhotosController.fetchedObjects?.first as! Photo
            self.topImageView.image = photo.image
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            
        })
        
    }
    
    
    
    /*
    Try to fetch the photos from Core Data
    */
    lazy var fetchedPhotosController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        if self.place != nil {
            fetchRequest.predicate = NSPredicate(format: "place == %@", self.place)            
        }
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
  
    @IBAction func didTouchEditButton() {
        if editButton.title == "Edit" {
            editButton.title = "Cancel"
            ratingSlider.hidden = false
            savedRatingLabel.hidden = true
            saveButton.hidden = false
            subLabel.text = "Change Your Rating"
        } else {
            editButton.title = "Edit"
            ratingSlider.hidden = true
            saveButton.hidden = true
            subLabel.text = "You Voted"
            savedRatingLabel.hidden = false
        }
  
        
    }
    
    @IBAction func didTouchSaveButton() {
        let slider = self.ratingSlider as! RatingSlider
        print(slider.ratingNumber)
        
        if slider.ratingNumber == 0 {
            errorLabel.hidden = false
            errorLabel.alpha = 1
            errorLabel.text = "No Rating Selected"
            UIView.animateWithDuration(1, animations: { () -> Void in
             self.errorLabel.alpha = 0
            })
        } else {
            print(place.title)
            print(place.entry?.title)
            
            
            place.rating = slider.ratingNumber
            saveContext()
            
            dismissViewControllerAnimated(true, completion: nil)
            navigationController?.popViewControllerAnimated(true)
        }
 
    }
    
    func hidePhotoTip() {
        
        self.photoTipLabel.hidden = true
    }
    
    func calulateColor(value: Int) -> UIColor{
        
        if value >= 5 {
            print("value: \(value)")
            let ratingPercent = ((105 - (Double(Double(value)/10.0) * 100)) * 0.01) * 255 * 2
            print ("rating percent: \(ratingPercent)")
            let color = UIColor(red: CGFloat(ratingPercent/255), green: 1, blue: 0, alpha: 1)
            return color
        } else {
            let ratingPercent = (Double(value)/10.0)
            let color = UIColor(red: 1, green: CGFloat(ratingPercent*255)/255, blue: 0, alpha: 1)
            return color
        }
    }
    

}
