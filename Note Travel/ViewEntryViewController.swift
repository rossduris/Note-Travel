//
//  ViewEntryViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 1/14/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewEntryViewController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var locationLabelTwo:UILabel!
    @IBOutlet weak var locationLabel:UILabel!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var cancelButton:UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addPlacesButton:UIButton!
    @IBOutlet weak var startWithPhotosButton:UIButton!
    @IBOutlet weak var buttonWrapperView:UIView!
    @IBOutlet weak var toggleButton:UIBarButtonItem!
    @IBOutlet weak var tableView:UITableView!
    
    var entry: Entry!
    
    
    
    
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
    
        mapView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configureUI()
        
        zoomToLocation()
    }
    
 
 
    
    
    /*
    
    TableView Delegate
    
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell")! as UITableViewCell
        
        cell.textLabel?.text = "No Locations"
        
        return cell
    }

    
    
    
    
    
    /*
    
    MapView Helpers
    
    */
    
    //Center and zoom on map to entry location
    func zoomToLocation() {
        let geocoder = CLGeocoder()
        let address = entry.title
        
        geocoder.geocodeAddressString(address) { (placemarks, error) -> Void in
            if error != nil {
                //self.toggleLoading(false, indicator: self.geoActivityIndicator, view: self.view)
                if error!.localizedDescription.rangeOfString("2") != nil{
                    //self.alertError("The operation could not be completed.", viewController: self)
                } else {
                    //self.alertError("The location you entered could not be found.", viewController: self)
                }
            } else {
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
            
            let span = MKCoordinateSpanMake(1.5, 1.5)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
            mapView.setRegion(region, animated: true)
        }
    }
 
    
    
    
    
    
    /*
    
    UI Helpers
    
    */
    func hideKeyboard(gestureRecognizer:UIGestureRecognizer) {
        print("hide")
        searchBar.resignFirstResponder()
    }
    
    func toggleMap(){
        if tableView.hidden{
            mapView.hidden = true
            tableView.hidden = false
            toggleButton.image = UIImage(named: "mapTab")
        } else {
            tableView.hidden = true
            mapView.hidden = false
            toggleButton.image = UIImage(named: "list")
        }
    }
    
    func toggleSearchBar(gestureRecognizer:UIGestureRecognizer){
        if searchBar.hidden {
            searchBar.hidden = false
        } else {
            searchBar.hidden  = true
        }
    }
    
    @IBAction func didPressCancelButton(){
        entry.newEntry = false
        //sharedContext.insertObject(entry)
        saveContext()
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func configureUI(){
        //Configure Navigation Controller
        navigationController?.navigationItem.title = entry.title
        tabBarController?.title = entry.title
        
        // Configure LongPress Gesture
        let tap = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        tap.delegate = self
        tap.numberOfTapsRequired  = 1
        mapView.addGestureRecognizer(tap)
        
        //Hide table view
        tableView.hidden = true
    }

    override func viewDidLayoutSubviews() {
        if entry.newEntry == false {
            locationLabel.hidden = true
            cancelButton.hidden = true
            navigationController?.title = entry.title
            navigationItem.rightBarButtonItem = nil
            startWithPhotosButton.hidden = true
            addPlacesButton.hidden = true
            locationLabelTwo.hidden = true
            searchBar.frame.origin.y -= 220
            tableView.frame.origin.y += 44
            mapView.frame = view.frame
        } else {
            locationLabel.text = entry.title
            navigationController?.navigationBar.hidden = true
            startWithPhotosButton.hidden = false
            addPlacesButton.hidden = false
        }
        
        let toggleButton =  UIBarButtonItem(image: UIImage(named: "list"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleMap")
        self.toggleButton = toggleButton
        self.parentViewController?.navigationItem.rightBarButtonItem = toggleButton
    }
    

}
