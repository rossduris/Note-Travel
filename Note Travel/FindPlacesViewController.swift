//
//  FindPlacesViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 2/12/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FindPlacesViewController: SharedViewController, MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var showListButton:UIButton!
    @IBOutlet weak var showMapButton:UIButton!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var tempResults = [Place]()
    var placemarks = [CLPlacemark]()
    var entry: Entry!
    
    
    
    
    /*
    Core Data Convenience
    */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var scratchContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator =  CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        return context
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }

    
    
    
    /*
    Lifecycle
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    
    
    
    
    /*
    Table View Delegate
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as UITableViewCell!
        
        cell.textLabel?.text = tempResults[indexPath.row].title
        print(tempResults[indexPath.row].id)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.hidden = true
        mapView.hidden = false
        if mapView.annotations.isEmpty {
            for place in tempResults {
                mapView.addAnnotation(place as Place)
                print(place.id)
            }
        }
        showListButton.hidden = false
        showMapButton.hidden = true
        searchBar.endEditing(true)
        
        let place = tempResults[indexPath.row]
        
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegion(center: place.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.selectAnnotation(place, animated: true)
    }
    

   
    
    
    /*
    Searchbar Helpers
    */
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        mapView.hidden = true
        tableView.hidden = false
        
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
     
        mapView.removeAnnotations(mapView.annotations)
        tempResults.removeAll()
        
        tableView.reloadData()
        
        let placemark = placemarks[0] as CLPlacemark
        let latitude = placemark.location?.coordinate.latitude
        let longitude = placemark.location?.coordinate.longitude
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        if searchBar.text == ""{
            tableView.reloadData()
        }
        
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        
        FoursquareClient.sharedInstance().searchFoursquareForPlace(searchText, latitude: latitude!, longitude: longitude!) { (success, places, error) in
            if success {
                self.tempResults = places
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            } else {
                print(error!)
                self.alertError(error!, viewController: self)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        tableView.hidden = true
        showListButton.hidden = false
        showMapButton.hidden = true
        mapView.hidden = false
        let placemark = placemarks[0] as CLPlacemark
        let location = CLLocationCoordinate2DMake((placemark.location?.coordinate.latitude)!, (placemark.location?.coordinate.longitude)!)
        let span = MKCoordinateSpanMake(0.2, 0.2)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: false)
        mapView.removeAnnotations(mapView.annotations)
        
        for place in tempResults {
            mapView.addAnnotation(place)
        }
        searchBar.endEditing(true)
    }
    
    
    
    
    
    /*
    Actions
    */
    @IBAction func didTouchCancelButton() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTouchShowListButton() {
        showListButton.hidden = true
        showMapButton.hidden = false
        mapView.hidden = true
        tableView.hidden = false
    }

    @IBAction func didTouchShowMapButton() {
        showListButton.hidden = false
        showMapButton.hidden = true
        mapView.hidden = false
        tableView.hidden = true
    }

 
    
    
    
    /*
    MapView Delegate
    */
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
        annotationView!.animatesDrop = true
        let tempButton = UIButton(type: .ContactAdd)
        let button = UIButton(type: .Custom)
        button.frame = tempButton.frame
        button.setImage(UIImage(named: "arrow"), forState: .Normal)
        annotationView!.rightCalloutAccessoryView = button
        annotationView!.pinTintColor = UIColor.redColor()
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("ViewPlaceViewController") as! ViewPlaceViewController
        
        let selectedPlace = view.annotation as! Place

        for previousPlace in entry.places {
            if previousPlace.id == selectedPlace.id {
                vc.place = previousPlace
            }
        }
        
        if vc.place == nil {
            let dictionary = [
                "name": selectedPlace.title!,
                "latitude": selectedPlace.latitude,
                "longitude": selectedPlace.longitude,
                "rating": 0,
                "id":selectedPlace.id
                ] as [String: AnyObject]
            
            let place = Place(dictionary: dictionary, context: self.sharedContext)
            place.entry = entry
            vc.place = place
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    /*
    UI
    */
    func prepareUI(){
        searchBar.delegate = self
        
        mapView.delegate = self
        mapView.hidden = true
        
        showMapButton.hidden = true
        
        searchBar.becomeFirstResponder()
        
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
        
        showListButton.hidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        title = "Find Places"
        searchBar.placeholder = "Find places in \(entry.title)"
    }
  

}
