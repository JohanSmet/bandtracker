//
//  BandsSeenController.swift
//  bandtracker
//
//  Created by Johan Smet on 20/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BandsSeenController:  UITableViewController,
                            NSFetchedResultsControllerDelegate,
                            MainTabSheet {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Band")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController (
                                            fetchRequest: fetchRequest,
                                            managedObjectContext: coreDataStackManager().managedObjectContext!,
                                            sectionNameKeyPath: nil,
                                            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the bands
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            // XXX
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SeenBandCell", forIndexPath: indexPath)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    private func configureCell(cell : UITableViewCell, indexPath : NSIndexPath) {
        
        let band = fetchedResultsController.objectAtIndexPath(indexPath) as! Band
        cell.textLabel?.text = band.name
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let band = fetchedResultsController.objectAtIndexPath(indexPath) as! Band
            dataContext().deleteBand(band)
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // NSFetchedResultsControllerDelegate
    //
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
                    forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
            case .Insert :
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete :
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update :
                configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
            case .Move :
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // MainTabSheet
    //
    
    func updateSearchResults(searchText : String) {
        
    }
    
    func addNewItem() {
        self.performSegueWithIdentifier("bandSearchSegue", sender: self)
    }
        
    var searchBarVisible : Bool { return true }
    var addButtonVisible : Bool { return true }
}