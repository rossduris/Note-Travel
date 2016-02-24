//
//  EntryTableViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 1/6/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import CoreData

class EntryTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var travelTableView: UITableView!
    @IBOutlet weak var entryTitleTextField:UITextField!
    var newEntry = false
    @IBOutlet weak var searchResulstsTableView:UITableView!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var newEntryButton:UIButton!
    @IBOutlet weak var newEntryButtonWrapper:UIView!
    @IBOutlet weak var editBarButton:UIBarButtonItem!
    var loading = false
    var searchController: UISearchController!
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
        
        travelTableView.delegate = self
        travelTableView.dataSource = self
        
        searchResulstsTableView.delegate = self
        searchResulstsTableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.hidden = true
        
        
        searchResulstsTableView.hidden = true
        
        loading(false)
        
        newEntryButtonWrapper.layer.borderWidth = 1
        newEntryButtonWrapper.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        
        fetchedEntriesController.delegate = self        
        
        fetchAllEntries()
    
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
    
    override func viewDidAppear(animated: Bool) {
        newEntryButtonWrapper.frame.origin.y -= 1
        if fetchedEntriesController.fetchedObjects?.count > 0 {
            editBarButton.title = "Edit"
        } else {
            editBarButton.title = ""
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        travelTableView.reloadData()
         wrapVisible = true
        if travelTableView.editing == true {
            editBarButton.title = "Done"
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchResulstsTableView.hidden = false
        searchBar.hidden = false
        
        editBarButton.title = "Cancel"
        editBarButton.action = "didTouchCancelButton"
    }
    
    @IBAction func didTouchEditButton() {
        
        print("go")
        if editBarButton.title == "Edit" {
            travelTableView.editing = true
            editBarButton.title = "Done"
        } else {
            travelTableView.editing = false
            editBarButton.title = "Edit"
        }
    }
    
    func didTouchCancelButton() {
        searchBar.endEditing(true)
        searchBar.hidden = true
        editBarButton.title = ""
        newEntryButtonWrapper.hidden = false
        searchResulstsTableView.hidden = true
        
        if fetchedEntriesController.fetchedObjects?.count > 0 {
            editBarButton.title = "Edit"
            editBarButton.action = "didTouchEditButton"
        } else {
            editBarButton.title = ""
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.loading(true)
        GoogleClient.sharedInstance().searchForCities(searchText) { (success: Bool, data: AnyObject) in
            if success {
                print("success")
        
                if let predictions = data["predictions"]{
                    self.searchResults.removeAll()
                    for prediction in (predictions as? NSArray)!{
                        print(prediction["description"]!!)
                        let string = prediction["description"]!!
    
                        self.searchResults.append(string)
                        self.searchResulstsTableView.reloadData()
                    }
                }
                self.loading(false)
            }
        }
        
    }
    
    func resignKeyboard(gestureRecognizer: UIGestureRecognizer){
        entryTitleTextField.resignFirstResponder()
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
            searchResulstsTableView.hidden = true
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
    
    @IBAction func refreshEntryPhotos() {
        travelTableView.reloadData()
    }
    

    @IBAction func didPressNewEntry() {
        newEntryButtonWrapper.hidden = true
        searchBar.becomeFirstResponder()
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
    
    
}

