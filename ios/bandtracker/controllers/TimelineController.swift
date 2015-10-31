//
//  TimelineController.swift
//  bandtracker
//
//  Created by Johan Smet on 21/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import UIKit
import CoreData

class TimelineController:   UITableViewController,
                            MainTabSheet {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Gig")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending:false)]
        
        let fetchedResultsController = NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStackManager().managedObjectContext!,
            sectionNameKeyPath: "year",
            cacheName: nil)
        // fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // execute the query
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath)  as! TimelineTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let theSection = self.fetchedResultsController.sections![section]
        let firstGig = theSection.objects![0] as! Gig
        return "\(firstGig.year)"
    }
    
    private func configureCell(cell : TimelineTableViewCell, indexPath : NSIndexPath) {
        let gig = fetchedResultsController.objectAtIndexPath(indexPath) as! Gig
        cell.setFields(gig)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // MainTabSheet
    //
    
    func updateSearchResults(searchText : String) {
        
    }
    
    func addNewItem() {
    }
    
    var searchBarVisible : Bool { return true }
    var addButtonVisible : Bool { return true }

}
