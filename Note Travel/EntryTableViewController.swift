//
//  EntryTableViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 1/6/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import CoreData

class EntryTableViewController: SharedViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var travelTableView: UITableView!

    @IBOutlet weak var searchResultsTableView:UITableView!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var newEntryButton:UIButton!
    @IBOutlet weak var newEntryButtonWrapper:UIView!
    @IBOutlet weak var editBarButton:UIBarButtonItem!
    @IBOutlet weak var refreshButton:UIBarButtonItem!

    var searchResults = [AnyObject]()
    var wrapVisible: Bool!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!


    
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
        
        fetchAllEntries()
    }
    override func viewDidAppear(animated: Bool) {
        newEntryButtonWrapper.frame.origin.y -= 1
        if fetchedEntriesController.fetchedObjects?.count > 0 {
            editBarButton.title = "Edit"
            refreshButton.enabled = true
        } else {
            refreshButton.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        travelTableView.reloadData()
        wrapVisible = true
        if travelTableView.editing == true {
            editBarButton.title = "Done"
        }
    }

    


    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let translation = scrollView.panGestureRecognizer.translationInView(scrollView.superview)
        
        if translation.y > 0 {
            //dragging down
            if wrapVisible == false{
                toggleWrapper(true)
                wrapVisible = true
            } else {
                //do nothing
            }
        } else {
            //dragging up
            if wrapVisible == false{
                //do nothing
            } else {
                toggleWrapper(false)
                wrapVisible = false
            }
        }
        
    }
    
    func toggleWrapper(visible: Bool){
        
        if visible == true {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.newEntryButtonWrapper.frame.origin.y += 56
            })
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.newEntryButtonWrapper.frame.origin.y -= 56
            })
        }
    }
    

    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchResultsTableView.hidden = false
        searchBar.hidden = false
        
        editBarButton.title = "Cancel"
        editBarButton.action = "didTouchCancelButton"
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        loading(true)
        searchResults.removeAll()
        GoogleClient.sharedInstance().searchForCities(searchText) { (success, results, error) in
            if success {
                self.searchResults = results
                self.searchResultsTableView.reloadData()
                self.loading(false)
            } else {
                print(error)
                self.alertError(error!, viewController: self)
            }
        }
        
    }
 
 
    
    func didTouchCancelButton() {
        searchBar.endEditing(true)
        searchBar.hidden = true
        editBarButton.title = ""
        newEntryButtonWrapper.hidden = false
        searchResultsTableView.hidden = true
        
        if fetchedEntriesController.fetchedObjects?.count > 0 {
            editBarButton.title = "Edit"
            editBarButton.action = "didTouchEditButton"
        } else {
            editBarButton.title = ""
        }
    }
    
    func loading(force:Bool) {
        if force {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
        }
    }
 
 

    /*
    Fetched Entries Controller
    */
    lazy var fetchedEntriesController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Entry")
        fetchRequest.sortDescriptors = []
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
                print(fetchedEntriesController.fetchedObjects?.count)
                
            case .Delete:
                print("delete")
                print(fetchedEntriesController.fetchedObjects?.count)
            default:
                return
            }
    }
    
    func fetchAllEntries() {
        do {
            try fetchedEntriesController.performFetch()
        } catch {
            print("error fetching")
        }
    }
    
    
    
    
    /*
    Table View Delegate
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == travelTableView {
            let sectionInfo = self.fetchedEntriesController.sections![section]
            return sectionInfo.numberOfObjects
        } else  {
            print(searchResults.count)
            return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == travelTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("travelCell", forIndexPath: indexPath) as! EntryCell
            let entry = fetchedEntriesController.objectAtIndexPath(indexPath) as! Entry
            cell.entryTitleLabel.text = entry.title
            if entry.photos.isEmpty {
             cell.entryPhotoView.image = UIImage(named: "entryPlaceholder")
            } else {
            
                var photos = [Photo]()
                for item in entry.photos{
                    if item.place?.rating > 6 {
                        photos.append(item)
                    }
                }
                
                if !photos.isEmpty {
                    let photoCount = photos.count
                    let randomPhoto = Int(arc4random_uniform(UInt32(photoCount)))
                    cell.entryPhotoView.image = photos[randomPhoto].image
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as UITableViewCell
            
            print(searchResults.count)
            cell.textLabel?.text = searchResults[indexPath.row] as? String
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == travelTableView {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("ViewEntryViewController") as! ViewEntryViewController
            let entry = fetchedEntriesController.objectAtIndexPath(indexPath) as! Entry
            vc.entry = entry
            navigationController?.pushViewController(vc, animated: true)
        } else {
            searchBar.endEditing(true)
            searchResultsTableView.hidden = true
            searchBar.text = ""
            newEntryButtonWrapper.hidden = false
            searchBar.hidden = true
            editBarButton.title = ""
            
            let title = searchResults[indexPath.row]
            print(title)
            let parts = title.componentsSeparatedByString(",")
            let string = "\(parts[0]),\(parts[1])"
            let dictionary = [
                "title": string
            ]
            let entry = Entry(dictionary: dictionary, context: sharedContext)
            saveContext()
            print("the title \(entry.title)")
            let vc = storyboard?.instantiateViewControllerWithIdentifier("ViewEntryViewController") as! ViewEntryViewController
            vc.entry = entry
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let entry = fetchedEntriesController.objectAtIndexPath(indexPath) as! Entry
            sharedContext.deleteObject(entry)
            saveContext()
            wrapVisible = true
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        }
    }
    
    
    
    
    /*
    Actions
    */
    @IBAction func didTouchEditButton() {
    
        if editBarButton.title == "Edit" {
            travelTableView.editing = true
            editBarButton.title = "Done"
        } else {
            travelTableView.editing = false
            editBarButton.title = "Edit"
        }
    }
    
    @IBAction func refreshEntryPhotos() {
        travelTableView.reloadData()
    }
    

    @IBAction func didPressNewEntry() {
        newEntryButtonWrapper.hidden = true
        searchBar.becomeFirstResponder()
    }
    
    
    
    /*
    UI
    */
    func prepareUI(){
        travelTableView.delegate = self
        travelTableView.dataSource = self
        
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.hidden = true
        
        searchResultsTableView.hidden = true
        
        loading(false)
        
        newEntryButtonWrapper.layer.borderWidth = 1
        newEntryButtonWrapper.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        fetchedEntriesController.delegate = self
    }
    
    
}

