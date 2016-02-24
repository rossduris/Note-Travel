//
//  ViewEntryViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 2/11/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewEntryViewController: SharedViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var menuBar:UIView!
    @IBOutlet weak var bottomRightBarButton:UIBarButtonItem!
    @IBOutlet weak var toolBar:UIToolbar!
    @IBOutlet weak var editButton:UIBarButtonItem!
    @IBOutlet weak var findPlaceButton:UIButton!

    var entry: Entry!
    var placemarks = [CLPlacemark]()
    
    
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
        
        prepareUI()
        
        fetchAllPlaces()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        showMenuBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        refreshPlaceData()
    }
    
    
  

 
    
    /*
    MapView Helpers
    */
    
    //Center and zoom on map to entry location
    func zoomToLocation(address:String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) -> Void in
            if error != nil {
                //self.toggleLoading(false, indicator: self.geoActivityIndicator, view: self.view)
                if error!.localizedDescription.rangeOfString("2") != nil{
                    self.alertError("The operation could not be completed.", viewController: self)
                   self.navigationController?.popViewControllerAnimated(true)
                } else {
                    self.alertError("The location you entered could not be found.", viewController: self)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            } else {
                self.placemarks = placemarks!
                self.geocodingCompleted(placemarks)
            }
        }
    }
    //Completion handler for the geocoder
    func geocodingCompleted(placemarks:[CLPlacemark]?) {
        //Stop loading
        //toggleLoading(false, indicator: geoActivityIndicator, view: view)
        
        if let placemark = placemarks?[0] as CLPlacemark! {
            //Save the location
            let latitude = placemark.location!.coordinate.latitude
            let longitude = placemark.location!.coordinate.longitude
            //let location = CLLocation(latitude: latitude, longitude: longitude)
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        if !(annotation is Place) {
            return nil
        }
        
        
        let reuseId = "pin"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        annotationView!.canShowCallout = true
        annotationView!.animatesDrop = false
        let tempButton = UIButton(type: .ContactAdd)
        let button = UIButton(type: .Custom)
        button.frame = tempButton.frame
        button.setImage(UIImage(named: "arrow"), forState: .Normal)
        annotationView!.rightCalloutAccessoryView = button
        let place = annotation as! Place
        annotationView!.pinTintColor = calculateColor(place.rating)
        
        return annotationView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("ViewPlaceViewController") as! ViewPlaceViewController
        
        let place = view.annotation as! Place
        print(place)
        vc.place = place
        saveContext()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    
    
    
    
    /*
    Table View Delegate
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedPlacesController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")  as! PlaceCell
        
        let place = fetchedPlacesController.objectAtIndexPath(indexPath) as! Place
        
        let title = place.name
        cell.colorTab.backgroundColor = calculateColor(place.rating)
        cell.ratingLabel.text = "\(place.rating)/10"
        cell.textLabel?.text = title
        
        if entry.places.count > 0 {
            if tableView.editing == true {
                editButton.title = "Done"
            } else {
                editButton.title = "Edit"
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let place = fetchedPlacesController.objectAtIndexPath(indexPath) as! Place
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let center = place.coordinate
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        mapView.selectAnnotation(place, animated: true)
        
        print(place.rating)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let place = fetchedPlacesController.objectAtIndexPath(indexPath) as! Place
            sharedContext.deleteObject(place)
            saveContext()
            mapView.removeAnnotation(place)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            if tableView.editing == true {
                editButton.title = "Done"
            }
            tableView.reloadData()
        }
        
    }
    
    
    
    
    
    
    /*
    Fetched Places Controller
    */
    lazy var fetchedPlacesController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Place")
        let sortDescriptor1 = NSSortDescriptor(key: "rating", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        fetchRequest.predicate = NSPredicate(format: "entry == %@", self.entry)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                print("insert")
                print(fetchedPlacesController.fetchedObjects?.count)
                
            case .Delete:
                print("delete")
                print(fetchedPlacesController.fetchedObjects?.count)
            default:
                return
            }
    }
    
    func fetchAllPlaces() {
        do {
            try fetchedPlacesController.performFetch()
        } catch {
            print("error fetching")
        }
    }
    
    
    /*
    Fade in Menu Bar
    */
    func showMenuBar(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.menuBar.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.menuBar.opaque = false
            self.menuBar.alpha = 0.8
        })
    }
    
    /*
    Refresh place content
    */
    func refreshPlaceData(){
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        let places = fetchedPlacesController.fetchedObjects as! [Place]
        for place in places {
            place.title = place.name
            mapView.addAnnotation(place)
        }
        
        tableView.reloadData()
    }
    
    
    
    @IBAction func didPressFindPlacesButton(){
        let vc = storyboard?.instantiateViewControllerWithIdentifier("FindPlacesViewController") as! FindPlacesViewController
        let nav = UINavigationController(rootViewController: vc)
        vc.placemarks = placemarks
        vc.entry = entry
        
        navigationController?.presentViewController(nav, animated: true, completion: nil)
    }
    
 
    
 
    
    @IBAction func didTouchEditButton(){
        if editButton.title == "Edit" {
            tableView.editing = true
            editButton.title = "Done"
        } else {
            tableView.editing = false
            editButton.title = "Edit"
        }

    }
    
    func prepareUI(){
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchedPlacesController.delegate = self
        
        title = entry.title
        
        mapView.delegate = self
        mapView.layoutMargins = UIEdgeInsetsMake(100, 0, +50, 0)
        
        menuBar.layer.borderWidth = 1
        menuBar.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        findPlaceButton.setTitle("Find places in \(entry.title)", forState: .Normal)
        
        zoomToLocation((entry?.title)!)
        
        if entry.places.count == 0 {
            editButton.title = ""
        } else {
            editButton.title = "Edit"
        }
    }
    
    
   
    
}
