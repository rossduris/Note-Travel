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

class FindPlacesViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var showListButton:UIButton!
    @IBOutlet weak var showMapButton:UIButton!
    
    var tempResults = [Place]()
    var placemarks = [CLPlacemark]()
    var entry: Entry!
    var searchBarVisible: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBarVisible = true
        
        mapView.delegate = self
        mapView.hidden = true
        
        showMapButton.hidden = true
        
        searchBar.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self, action: "didTapMap:")
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tap)
        
        showListButton.hidden = true
        
        tableView.delegate = self
        tableView.dataSource = self

        title = "Find Places"
        searchBar.placeholder = "Find places in \(entry.title)"
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    
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
    
    
    func didTapMap(sender: UIGestureRecognizer) {
//        if searchBarVisible == true {
//            toggleSearchBar(false)
//        } else {
//            toggleSearchBar(true)
//        }
    }
    
    func toggleSearchBar(visible: Bool) {
        if visible {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.searchBar.frame.origin.y += 44
                //self.mapView.frame.origin.y += 44
                self.searchBarVisible = true
            })
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.searchBar.frame.origin.y -= 44
                //self.mapView.frame = self.view.frame
                self.searchBarVisible = false
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as UITableViewCell!
        
        cell.textLabel?.text = tempResults[indexPath.row].title
        print(tempResults[indexPath.row].id)
        return cell
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == ""{
            //searchResults.removeAll()
            //searchResultLocations.removeAll()
            tempResults.removeAll()
            tableView.reloadData()
        }
        
        
        let placemark = placemarks[0] as CLPlacemark
        let latitude = placemark.location?.coordinate.latitude
        let longitude = placemark.location?.coordinate.longitude
        
        FoursquareClient.sharedInstance().searchFoursquareForPlace(searchText, latitude: latitude!, longitude: longitude!) { (success: Bool, data: AnyObject) in
            if success {
                if let response = data["response"] as? [String: AnyObject]  {
                    if let venues = response["venues"] {

                        self.tempResults.removeAll()
                        for venue in (venues as? NSArray)! {

                            
                            if let location = venue["location"] {
                                if let lat = location!["lat"], let lng = location!["lng"] {
                                    
                                   
                                    if let name = venue["name"] {

                                        
                                        let title = name as! String
                                        let latitude = lat as! CLLocationDegrees
                                        let longitude = lng as! CLLocationDegrees
                         
                                        if let id = venue["id"] as? String {

                                            
                                let dictionary = [
                                    "name": title,
                                    "latitude": latitude,
                                    "longitude": longitude,
                                    "id":id
                                    ] as [String: AnyObject]
                                print(id)
                                let place = Place(dictionary: dictionary, context: self.scratchContext)

                                            //place.entry = self.entry
                                            place.title = title
                                            self.tempResults.append(place)                                        
                                            self.tableView.reloadData()
                                        }
                                        

                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
//        GoogleClient.sharedInstance().searchForNearbyPlaces(searchText, location: location) { (success:Bool, data: AnyObject) in
//            if success {
//                if let results = data["results"] as? NSArray{
//                    self.searchResults.removeAll()
//                    self.searchResultLocations.removeAll()
//                    for result in results {
//                        print(result["geometry"])
//                        if let geometry = result["geometry"]{
//                            print(geometry!["location"])
//                            if let location = geometry!["location"] {
//                                print(location!)
//                                if let latitude = location!["lat"], let longitude = location!["lng"], let searchResult = result["name"]!
//                                {
//                                    let title = searchResult as! String
//                                    let lat = latitude as! CLLocationDegrees
//                                    let lng = longitude as! CLLocationDegrees
//                                    let coordinate = CLLocationCoordinate2DMake(lat, lng)
//                                    let annotation = SearchPinAnnotation()
//                                    annotation.coordinate = coordinate
//                                    annotation.title = title
//                                    self.searchResultLocations.append(annotation)
//                                    self.searchResults.append(searchResult as! String)
//                                    self.tableView.reloadData()
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        mapView.hidden = true
        tableView.hidden = false
        
        return true
    }
    
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("ViewPlaceViewController") as! ViewPlaceViewController
        
        let selectedPlace = view.annotation as! Place

        let dictionary = [
            "name": selectedPlace.title!,
            "latitude": selectedPlace.latitude,
            "longitude": selectedPlace.longitude,
            "id":selectedPlace.id
            ] as [String: AnyObject]
        
        let place = Place(dictionary: dictionary, context: self.sharedContext)
        place.entry = entry
        vc.place = place
        navigationController?.pushViewController(vc, animated: true)
        
//        let annotationView = view as! MKPinAnnotationView
//        annotationView.pinTintColor = UIColor.purpleColor()
//        let dictionary = ["title": (view.annotation?.title!!)!] as [String: AnyObject]
//        let place = Place(dictionary: dictionary, context: sharedContext)
//        place.entry = entry
//        saveContext()
    }
    
//    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
//        var customView = (NSBundle.mainBundle().loadNibNamed("SearchPin", owner: self, options: nil))[0] as! PlacePinView
//        let cpa = view.annotation as! SearchPinAnnotation
//        view.addSubview(customView)
//    }
//    
//    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
//        view.subviews.first?.hidden = true
//    }
    
    
   


}
