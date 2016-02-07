//
//  EntryTableViewController.swift
//  Note Travel
//
//  Created by Ross Duris on 1/6/16.
//  Copyright © 2016 duris.io. All rights reserved.
//

import UIKit
import CoreData

class EntryTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var travelTableView: UITableView!
    @IBOutlet weak var entryTitleTextField:UITextField!
    var tempEntry:Entry!
    var newEntry = false
    
    
    
    
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
        
        fetchedEntriesController.delegate = self
        
        fetchAllEntries()
        
//        let tap = UITapGestureRecognizer(target: self, action: "resignKeyboard:")
//        tap.delegate = self
//        tap.numberOfTapsRequired = 1
//        travelTableView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        travelTableView.reloadData()
        
    }
    
    
    
    /*
    Fetched Entries Controller
    */
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
        let sectionInfo = self.fetchedEntriesController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("travelCell", forIndexPath: indexPath) as UITableViewCell
        
        let entry = fetchedEntriesController.objectAtIndexPath(indexPath) as! Entry
        cell.textLabel?.text = entry.title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        newEntry = false
        performSegueWithIdentifier("toTabController", sender: self)
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toTabController" {
            let tabBarC = segue.destinationViewController as! UITabBarController
            let desinationView: ViewEntryViewController = tabBarC.viewControllers?.first as! ViewEntryViewController
            
            if newEntry{
                print("new entry")
                print(tempEntry)
                tempEntry.newEntry = true
                desinationView.entry = tempEntry
            } else {
                print("previous entry")
                let indexPath = travelTableView!.indexPathForSelectedRow!
                let entry = fetchedEntriesController.objectAtIndexPath(indexPath) as! Entry
                entry.newEntry = false
                desinationView.entry = entry
            }
        }
    }
    
    
    @IBAction func addEntry(){
        if entryTitleTextField.text != "" {
            let dictionary : [String : AnyObject] = ["title" : entryTitleTextField.text!]
            let entry = Entry(dictionary: dictionary, context: sharedContext)
            entryTitleTextField.resignFirstResponder()
            entryTitleTextField.text = ""
            sharedContext.insertObject(entry)
            saveContext()
            travelTableView.reloadData()
            newEntry = true
            tempEntry = entry
            
            performSegueWithIdentifier("toTabController", sender: self)
        }
        
    }
}

