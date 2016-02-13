//
//  EditEntryViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 2/11/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import MapKit

class EditEntryViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var menuBar:UIView!
    @IBOutlet weak var bottomRightBarButton:UIBarButtonItem!
    @IBOutlet weak var toolBar:UIToolbar!
    var entry: Entry?
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
        
        mapView.delegate = self
        mapFrame = mapView.frame

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
        
        menuBar.layer.borderWidth = 1
        menuBar.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        wrapVisible = true
        mapOpen = false
    }
    

    func swipeUp(sender: UIGestureRecognizer){
        if mapOpen == true {
            openMap(false)
        }
    }
    
    func swipeDown(sender: UIGestureRecognizer){
        if wrapVisible == false {
            toggleMap(true)
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

    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let translation = scrollView.panGestureRecognizer.translationInView(scrollView.superview)
 
        if translation.y > 0 {
            //dragging down
            if wrapVisible == false{
                
            } else {
                
            }
            
        } else {
            //dragging up
            if wrapVisible == false{
                
            } else {
                toggleMap(false)
            }
        }
    }
    
//    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        openMap()
//    }
//    
    

    func openMap(doOpen:Bool){

        if doOpen == true {
            if mapOpen == false {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                var frame = self.view.frame
                frame.origin.x = self.mapView.frame.origin.x
                self.origin = self.mapView.frame.origin.x
                self.mapView.frame = frame
                self.tableView.frame.origin.y += 320
                self.menuBar.frame.origin.y += 324
                self.mapOpen = true
            })
            }
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                var frame = self.mapFrame
                frame.origin.x = self.origin
                self.mapView.frame = frame
                self.tableView.frame.origin.y -= 320
                self.menuBar.frame.origin.y -= 324
                self.mapOpen = false
            })
        }
        
    }
 
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            if wrapVisible == false{
                toggleMap(true)
            } 
        }
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        toggleMap(true)
        return true
    }
    
    func toggleMap(visible: Bool){
        
        if visible == true {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.mapView.frame.origin.y += 186
                self.menuBar.frame.origin.y += 183
                self.tableView.frame.origin.y += 246
            })
            wrapVisible = true
            mapOpen = false
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.mapView.frame.origin.y -= 186
                self.menuBar.frame.origin.y -= 183
                self.tableView.frame.origin.y -= 246
            })
            wrapVisible = false
            mapOpen = false
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
    
    @IBAction func didPressFindPlacesButton(){
        let vc = storyboard?.instantiateViewControllerWithIdentifier("FindPlacesViewController") as! FindPlacesViewController
        vc.placemarks = placemarks
        vc.entryTitle = entry?.title
        navigationController?.pushViewController(vc, animated: true)
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
            
            let span = MKCoordinateSpanMake(0.25, 0.25)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")  as UITableViewCell!
        cell.textLabel?.text = "hello"
        return cell
    }

}
