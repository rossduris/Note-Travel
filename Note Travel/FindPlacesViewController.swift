//
//  FindPlacesViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 2/12/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import MapKit

class FindPlacesViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var showListButton:UIButton!
    
    var searchResults = [String]()
    var searchResultLocations = [CLLocation]()
    var placemarks = [CLPlacemark]()
    var entryTitle: String!
    var searchBarVisible: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBarVisible = true
        
        mapView.delegate = self
        mapView.hidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: "didTapMap:")
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tap)
        
        showListButton.hidden = true
        
        tableView.delegate = self
        tableView.dataSource = self

        title = "Add Place"
        searchBar.placeholder = "Find places in \(entryTitle)"
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func didTapMap(sender: UIGestureRecognizer) {
        if searchBarVisible == true {
            toggleSearchBar(false)
        } else {
            toggleSearchBar(true)
        }
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
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as UITableViewCell!
        
        cell.textLabel?.text = searchResults[indexPath.row]
        return cell
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == ""{
            searchResults.removeAll()
            self.tableView.reloadData()
        }
        let placemark = placemarks[0] as CLPlacemark
        let latitude = placemark.location?.coordinate.latitude
        let longitude = placemark.location?.coordinate.longitude
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        GoogleClient.sharedInstance().searchForNearbyPlaces(searchText, location: location) { (success:Bool, data: AnyObject) in
            if success {
                if let results = data["results"] as? NSArray{
                    self.searchResults.removeAll()
                    self.searchResultLocations.removeAll()
                    for result in results {
                        print(result["geometry"])
                        if let geometry = result["geometry"]{
                            print(geometry!["location"])
                            if let location = geometry!["location"] {
                                print(location!)
                                if let latitude = location!["lat"], let longitude = location!["lng"], let searchResult = result["name"]
                                {
                                    let lat = latitude as! CLLocationDegrees
                                    let lng = longitude as! CLLocationDegrees
                                    let location = CLLocation(latitude: lat, longitude: lng)
                                    self.searchResultLocations.append(location)
                                    self.searchResults.append(searchResult as! String)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        mapView.hidden = true
        tableView.hidden = false
        
        return true
    }
    
    @IBAction func didTouchShowListButton() {
        if showListButton.titleLabel?.text == "Show List" {
            showListButton.titleLabel?.text = "Show Map"
            mapView.hidden = true
            tableView.hidden = false
        } else {
            showListButton.titleLabel?.text = "Show List"
            mapView.hidden = false
            tableView.hidden = true
        }

    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        tableView.hidden = true
        showListButton.hidden = false
        mapView.hidden = false
        let placemark = placemarks[0] as CLPlacemark
        let location = CLLocationCoordinate2DMake((placemark.location?.coordinate.latitude)!, (placemark.location?.coordinate.longitude)!)
        let span = MKCoordinateSpanMake(0.2, 0.2)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: false)
        mapView.removeAnnotations(mapView.annotations)
        for location in searchResultLocations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            mapView.addAnnotation(annotation)
            searchBar.endEditing(true)
        }
    }

}
