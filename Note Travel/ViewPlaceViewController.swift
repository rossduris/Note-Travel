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

class ViewPlaceViewController: SharedViewController, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var saveButton:UIButton!
    @IBOutlet weak var topImageView:UIImageView!
    @IBOutlet weak var ratingSlider:UIView!
    @IBOutlet weak var subLabel:UILabel!
    @IBOutlet weak var tempLabel:UILabel!
    @IBOutlet weak var photoTipLabel:UILabel!
    @IBOutlet weak var errorLabel:UILabel!
    @IBOutlet weak var noPhotosLabel:UILabel!
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
    
    
    
    
    /*
    Lifecycle
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPhotos()
        
        prepareUI()
        
        downloadImages()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if place.rating == 0 {
            sharedContext.deleteObject(place)
        }
    }
    
 
    
    
    /*
    Image Helpers
    */
    func didLoadImage(notification: NSNotification) {

        print("ImageLoadedNotification")
        self.photoTipLabel.hidden = false
        self.noPhotosLabel.hidden = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
    }
    
    func loadRandomPhoto(){
        photoTipLabel.hidden = true
        let photoCount = place.photos.count
        let randomPhoto = Int(arc4random_uniform(UInt32(photoCount)))
        UIView.animateWithDuration(1, animations: { () -> Void in
            
            self.topImageView.alpha = 0.5
            self.topImageView.image = self.place.photos[randomPhoto].image
            self.topImageView.alpha = 1
            
        })
    }
    
    func downloadImages() {
        if place.photos.isEmpty {
            self.noPhotosLabel.hidden = false
            self.noPhotosLabel.text = "Loading Photos"
            FoursquareClient.sharedInstance().downloadPhotos(place.id, entry: self.place.entry!, place: self.place! ) { (success, photos, error) in
                if success {
                    self.topImageView.image = photos.first?.image
                } else {
                    self.alertError(error!, viewController: self)
                    if error! == "No photos found" {
                        self.noPhotosLabel.text = "No photos found"
                        self.noPhotosLabel.hidden = false
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                        self.noPhotosLabel.hidden = false
                    }
                
                }
            }
        } else  {
            let photo = self.fetchedPhotosController.fetchedObjects?.first as! Photo
            self.topImageView.image = photo.image
        }
    }
    
    
    
    
    
    /*
    FetchedPhotosController
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
    
    
    
    
    /*
    Actions
    */
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
    
    
    /*
    UI
    */
    func prepareUI(){
        
        fetchedPhotosController.delegate = self
        
        let slider = self.ratingSlider as! RatingSlider
        
        savedRatingLabel.layer.cornerRadius = savedRatingLabel.frame.width/2        
        
        if place.rating != 0 {
            print(place.rating)
            slider.hidden = true
            
            savedRatingLabel.textColor = calculateColor(place.rating)
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
        savedRatingLabel.textColor = calculateColor(place.rating)
        
        //Notification observer for when an image is downloaded
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoadImage:", name: "ImageLoadedNotification", object: nil)
        
        title = place.name
        
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
    }
    
    
 

}
