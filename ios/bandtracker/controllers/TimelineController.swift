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
                            NSFetchedResultsControllerDelegate,
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
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    var keyboardFix : KeyboardFix?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //

    override func viewDidLoad() {
        super.viewDidLoad()
        updateSearchResults("")
        
        keyboardFix = KeyboardFix(viewController: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // handle keyboard properly
        if let keyboardFix = self.keyboardFix {
            keyboardFix.activate()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let keyboardFix = self.keyboardFix {
            keyboardFix.deactivate()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath)  as! TimelineTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let theSection = self.fetchedResultsController.sections![section]
        let firstGig = theSection.objects![0] as! Gig
        return "\(firstGig.year)"
    }
    
    private func configureCell(cell : TimelineTableViewCell?, indexPath : NSIndexPath) {
        guard let cell = cell else { return }
        guard let gig = fetchedResultsController.objectAtIndexPath(indexPath) as? Gig else { return }
        cell.setFields(gig)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let gig     = fetchedResultsController.objectAtIndexPath(indexPath) as! Gig
        let newVC   = GigDetailsController.displayGig(gig)
        navigationController?.pushViewController(newVC, animated: true)
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
                if indexPath == nil {       // Swift 2.0 BUG with running 8.4
                    tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                }
            case .Delete :
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update :
                configureCell(tableView.cellForRowAtIndexPath(indexPath!) as? TimelineTableViewCell, indexPath: indexPath!)
            case .Move :
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch (type) {
            case .Insert :
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete :
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default :
                false
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
        // update the predicate to correspond to the filter string
        if searchText.characters.count > 0 {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "band.name CONTAINS[cd] %@", searchText)
        } else {
            fetchedResultsController.fetchRequest.predicate = nil
        }
        
        // execute the query again
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }
    
    func addNewItem() {
        // not needed here
    }
    
    var searchBarVisible : Bool { return true }
    var addButtonVisible : Bool { return false }

}
