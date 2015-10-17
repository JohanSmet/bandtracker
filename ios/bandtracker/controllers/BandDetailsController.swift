//
//  BandDetailsController.swift
//  bandtracker
//
//  Created by Johan Smet on 26/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BandDetailsController :   UIViewController,
                                UITableViewDataSource,
                                UITableViewDelegate,
                                NSFetchedResultsControllerDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var band : Band!
    
    lazy var gigFetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Gig")
        fetchRequest.predicate       = NSPredicate(format: "band.bandMBID == %@", self.band.bandMBID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
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
    // outlets
    //
    
    @IBOutlet var pageTitle: UINavigationItem!
    @IBOutlet var bandImage: UIImageView!
    @IBOutlet var biography: UITextView!
    @IBOutlet weak var tableGigs: UITableView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var gigTitle: UILabel!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableGigs.dataSource = self
        tableGigs.delegate = self
        
        // load the gigs
        do {
            try gigFetchedResultsController.performFetch()
        } catch let error as NSError {
            // XXX
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        pageTitle.title         = band.name
        biography.text          = band.biography
        ratingControl.rating    = band.rating()
        gigTitle.text           = "You have been to \(band.gigs.count) gigs :"
        
        UrlFetcher.loadImageFromUrl(band.imageUrl) { image in
            self.bandImage.image = image
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func addGig(sender: AnyObject) {
        let newVC = GigDetailsController.createNewGig(band)
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.gigFetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = gigFetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("gigSeenCell", forIndexPath: indexPath)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell : UITableViewCell, indexPath : NSIndexPath) {
        let gig = gigFetchedResultsController.objectAtIndexPath(indexPath) as! Gig
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .MediumStyle
        dateFormat.timeStyle = .NoStyle
        
        cell.textLabel?.text = dateFormat.stringFromDate(gig.startDate) + " " + (gig.city?.name ?? "")
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let gig = gigFetchedResultsController.objectAtIndexPath(indexPath) as! Gig
        let newVC = GigDetailsController.displayGig(gig)
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // NSFetchedResultsControllerDelegate
    //
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableGigs.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch (type) {
            case .Insert :
                tableGigs.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete :
                tableGigs.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update :
                configureCell(tableGigs.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
            case .Move :
                tableGigs.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableGigs.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableGigs.endUpdates()
    }
}