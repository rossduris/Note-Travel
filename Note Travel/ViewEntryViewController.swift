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
    @IBOutlet weak var toggleButton:UIBarButtonItem!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var buttonWrapperView:UIView!
    @IBOutlet weak var newEntryView: UIView!


    
    var selectedLocation:String?
    var searchString:String!
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
   
        
        print("here")
        print(selectedLocation)
        
        configureUI()
        
        if entry == nil {
            setTabBarHidden(true)
            buttonWrapperView.hidden = false
            navigationController?.navigationBar.hidden = true
            
            //searchBar.hidden = true

        } else {
            //searchBar.hidden = false
        }
        
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
        
        geocoder.geocodeAddressString(selectedLocation!) { (placemarks, error) -> Void in
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
        //setTabBarHidden(true)
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

        //sharedContext.insertObject(entry)
        saveContext()
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func configureUI(){
        //Configure Navigation Controller
        navigationController?.navigationItem.title = searchString
        tabBarController?.title = searchString
        
        // Configure LongPress Gesture
        let tap = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        tap.delegate = self
        tap.numberOfTapsRequired  = 1
        mapView.addGestureRecognizer(tap)
        
        //Hide table view
        tableView.hidden = true
    }
    
    @IBAction func didTouchStartWithPhotosButton(){
        navigationController?.navigationBar.hidden = false
        startWithPhotosButton.hidden = true
        addPlacesButton.hidden = true
        searchBar.frame.origin.y -= 220
        tableView.frame.origin.y += 44
        mapView.frame = view.frame
        buttonWrapperView.hidden = true
        tabBarController?.selectedIndex = 1
        
        setTabBarHidden(false)
        
        searchBar.hidden = false

    }
    
    @IBAction func didTouchStartWithSearchButton(){
        print("touhcy")
        navigationController?.navigationBar.hidden = false

        locationLabel.hidden = true
        cancelButton.hidden = true
        buttonWrapperView.hidden = true

        
        setTabBarHidden(false)
        showSearchBar()
        expandMap()
 
        //searchBar.becomeFirstResponder()
    }
    
    func expandMap(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mapView.frame = self.view.frame
        })
    }
    
    func showSearchBar(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.searchBar.frame.origin.y += 108
        })
    }
    
    func setTabBarHidden (bool:Bool){
        for view in tabBarController!.view.subviews {
            if (view.isKindOfClass(UITabBar)){
                let tabBar = view as! UITabBar
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    var offset = CGFloat(50)
                    if (bool == false){
                        offset = -50;
                    }
                    tabBar.frame = CGRect(origin: CGPointMake(tabBar.frame.origin.x, tabBar.frame.origin.y + offset), size: tabBar.frame.size)
                })
            }
        }
    }

    override func viewDidLayoutSubviews() {
        
        if selectedLocation != nil {
            locationLabel.text = selectedLocation
            //navigationController?.navigationBar.hidden = true
            
            mapView.frame.origin.y += 220
            searchBar.frame.origin.y -= 64
            tabBarController?.title = selectedLocation
            searchString = selectedLocation

        } else {

            navigationController?.navigationBar.hidden = false
            locationLabel.hidden = true
            cancelButton.hidden = true
            tabBarController?.title = entry.title
            navigationItem.rightBarButtonItem = nil
            buttonWrapperView.hidden = true
            
            locationLabelTwo.hidden = true
            searchBar.frame.origin.y -= 220
            tableView.frame.origin.y += 50
            mapView.frame = view.frame
            searchString = entry.title
        }
        
        let toggleButton =  UIBarButtonItem(image: UIImage(named: "list"), style: UIBarButtonItemStyle.Plain, target: self, action: "toggleMap")
        self.toggleButton = toggleButton
        self.parentViewController?.navigationItem.rightBarButtonItem = toggleButton
    }
    

}
