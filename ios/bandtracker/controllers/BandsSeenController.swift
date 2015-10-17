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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "totalRating", ascending:false), NSSortDescriptor(key: "name", ascending: true)]
        
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
        updateSearchResults("")
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SeenBandCell", forIndexPath: indexPath) as! SeenBandTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    private func configureCell(cell : SeenBandTableViewCell, indexPath : NSIndexPath) {
        
        let band = fetchedResultsController.objectAtIndexPath(indexPath) as! Band
        
        cell.bandName.text          = band.name
        cell.numberOfGigs.text      = "(\(band.gigs.count) gigs)"
        cell.ratingControl.rating   = band.totalRating.floatValue / (Float(band.gigs.count) * 10)
        cell.bandImage.image        = nil
        
        UrlFetcher.loadImageFromUrl(band.imageUrl) { image in
            cell.bandImage.image = image
        }
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailVc = self.storyboard?.instantiateViewControllerWithIdentifier("BandDetailsController") as! BandDetailsController
        detailVc.band = fetchedResultsController.objectAtIndexPath(indexPath) as! Band
        self.navigationController?.showViewController(detailVc, sender: self)
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
                configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! SeenBandTableViewCell, indexPath: indexPath!)
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
        
        // update the predicate to correspond to the filter string
        if searchText.characters.count > 0 {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
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
        self.performSegueWithIdentifier("bandSearchSegue", sender: self)
    }
        
    var searchBarVisible : Bool { return true }
    var addButtonVisible : Bool { return true }
}