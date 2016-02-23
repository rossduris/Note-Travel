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

class ViewEntryViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var menuBar:UIView!
    @IBOutlet weak var bottomRightBarButton:UIBarButtonItem!
    @IBOutlet weak var toolBar:UIToolbar!

    var entry: Entry!
    var wrapVisible: Bool!
    var mapOpen: Bool!
    var mapChangedFromUserInteraction = false
    var mapFrame: CGRect!
    var origin:CGFloat!
    var placemarks = [CLPlacemark]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchedPlacesController.delegate = self
        
        mapView.delegate = self
        mapFrame = mapView.frame
        
        
        
        //mapView.layoutMargins = UIEdgeInsetsMake(0, 0, -20, 0)
        menuBar.layer.borderWidth = 1
        menuBar.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        print(entry?.title)
        title = entry?.title
        let address = entry?.title
        zoomToLocation(address!)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "swipeUp:")
        swipeUp.direction = .Up
        swipeUp.delegate = self
        menuBar.addGestureRecognizer(swipeUp)
        let swipeUp2 = UISwipeGestureRecognizer(target: self, action: "swipeUp:")
        swipeUp2.direction = .Up
        swipeUp2.delegate = self
        toolBar.addGestureRecognizer(swipeUp2)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "swipeDown:")
        swipeDown.direction = .Down
        swipeDown.delegate = self
        menuBar.addGestureRecognizer(swipeDown)
        
        
        
        fetchAllPlaces()
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
        self.menuBar.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.menuBar.opaque = false
        self.menuBar.alpha = 0.8
        })
    
    }
    
    override func viewWillAppear(animated: Bool) {
        wrapVisible = true
        mapOpen = false
        
        let places = fetchedPlacesController.fetchedObjects as! [Place]
        
        if fetchedPlacesController.fetchedObjects?.isEmpty == nil {
            zoomToLocation((entry?.title)!)
        }
        
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }

        
        for place in places {
            place.title = place.name
            mapView.addAnnotation(place)
        }
        
        
        tableView.reloadData()
    }
    
    
    
    /*
    Core Data Convenience
    */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    

    func swipeUp(sender: UIGestureRecognizer){
        if mapOpen == true {
            openMap(false)
        }
    }
    
    func swipeDown(sender: UIGestureRecognizer){
        if mapOpen == false {
            openMap(true)
        }
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let userChange = mapViewRegionDidChangeFromUserInteraction()
        if userChange {
            openMap(true)
        }
    }

    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended ) {
                    return true
                }
            }
        }
        return false
    }



    func openMap(doOpen:Bool){

        if doOpen == true {
            if mapOpen == false {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                var frame = self.view.frame
                frame.origin.x = self.mapView.frame.origin.x
                self.origin = self.mapView.frame.origin.x
                self.mapView.frame = frame
                self.mapView.center = self.view.center
                self.tableView.frame.origin.y += 324
                self.menuBar.frame.origin.y += 324
                self.mapOpen = true
            })
            }
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.mapView.frame = self.mapFrame
                self.mapView.center = self.view.center
                self.mapView.frame.origin.y -= 152
                self.tableView.frame.origin.y -= 324
                self.menuBar.frame.origin.y -= 324
                self.mapOpen = false
            })
        }
        
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
                    //self.alertError("The operation could not be completed.", viewController: self)
                } else {
                    //self.alertError("The location you entered could not be found.", viewController: self)
                }
            } else {
                self.placemarks = placemarks!
                self.geocodingCompleted(placemarks)
            }
        }
    }
    
//    @IBAction func launchPhotoBrowser()
//    {
//        let photoBrowserViewController = PhotoBrowserViewController()
//        
//        photoBrowserViewController.delegate = self
//        
//        photoBrowserViewController.launch(size: CGSize(width: view.frame.width - 100, height: view.frame.height - 100), view: view)
//    }
    
    @IBAction func didPressFindPlacesButton(){
        let vc = storyboard?.instantiateViewControllerWithIdentifier("FindPlacesViewController") as! FindPlacesViewController
        let nav = UINavigationController(rootViewController: vc)
        vc.placemarks = placemarks
        vc.entry = entry
        
        navigationController?.presentViewController(nav, animated: true, completion: nil)
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
            
            let span = MKCoordinateSpanMake(0.10, 0.10)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
            if ((fetchedPlacesController.fetchedObjects?.isEmpty) == nil) {
                mapView.setRegion(region, animated: true)
            } else {
                mapView.setRegion(region, animated: false)
            }
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
        annotationView!.pinTintColor = UIColor.purpleColor()
        
        return annotationView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedPlacesController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")  as UITableViewCell!
        
        let place = fetchedPlacesController.objectAtIndexPath(indexPath) as! Place
        
        let title = place.name
        print(title)
        cell.textLabel?.text = title
        
        return cell
    }
    
    /*
    Fetched Places Controller
    */
    lazy var fetchedPlacesController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Place")
        fetchRequest.sortDescriptors = []
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let place = fetchedPlacesController.objectAtIndexPath(indexPath) as! Place
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: place.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.selectAnnotation(place, animated: true)
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
        }
    }

    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("ViewPlaceViewController") as! ViewPlaceViewController
        
        let place = view.annotation as! Place
        vc.place = place
        navigationController?.pushViewController(vc, animated: true)

    }
    
}
