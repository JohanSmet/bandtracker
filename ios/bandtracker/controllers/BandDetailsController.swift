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
                                NSFetchedResultsControllerDelegate,
                                CoreDataObserverDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var band            : Band!
    var tourDateYears   : [Int] = []
    
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
    
    private var coreDataObserver : CoreDataObserver!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet var pageTitle: UINavigationItem!
    @IBOutlet var bandImage: UIImageView!
    @IBOutlet weak var imageIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableGigs: UITableView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var gigTitle: UILabel!
    
    @IBOutlet weak var biography: UITextView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // class functions
    //
    
    class func create(band : Band) -> BandDetailsController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let newVc = storyboard.instantiateViewControllerWithIdentifier("BandDetailsController") as! BandDetailsController
        newVc.band = band
        
        return newVc
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // track any changes to the band record
        coreDataObserver = CoreDataObserver(context: band.managedObjectContext!)
        coreDataObserver.delegate = self
        
        // init tableview
        tableGigs.dataSource = self
        tableGigs.delegate = self
        
        // load the gigs
        do {
            try gigFetchedResultsController.performFetch()
        } catch let error as NSError {
            // XXX
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // see what years are available on the server
        bandTrackerClient().tourDateYears(band.bandMBID) { years, error in
            if let years = years {
                let curYear = DateUtils.currentYear()
                self.tourDateYears = years.filter() { $0 > 1970 && $0 <= curYear }
            }
        }
        
        setUIFields()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        biography.setContentOffset(CGPointMake(0,0), animated: false)
        biography.scrollEnabled = true
        
        coreDataObserver.startObservingObject(band)
        
        setGigTitle()
        setBandimage()
        ratingControl.rating    = band.avgRating.floatValue
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        coreDataObserver.stopObservingObject(band)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func addGig(sender: AnyObject) {
        if !tourDateYears.isEmpty {
            let newVC = GigGuidedCreationController.create(band!, tourDateYears: tourDateYears)
            navigationController?.pushViewController(newVC, animated: true)
        } else {
            let newVC = GigDetailsController.createNewGig(band!)
            navigationController?.pushViewController(newVC, animated: true)
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("gigSeenCell", forIndexPath: indexPath) as! SeenGigTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell : SeenGigTableViewCell?, indexPath : NSIndexPath) {
        guard let cell = cell else { return }
        guard let gig = gigFetchedResultsController.objectAtIndexPath(indexPath) as? Gig else { return }
        
        cell.setFields(gig)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let gig = gigFetchedResultsController.objectAtIndexPath(indexPath) as! Gig
        let newVC = GigDetailsController.displayGig(gig)
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let gig = gigFetchedResultsController.objectAtIndexPath(indexPath) as! Gig
            dataContext().deleteGig(gig)
        }
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
                if indexPath == nil {       // Swift 2.0 BUG with running 8.4
                    tableGigs.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                }
            case .Delete :
                tableGigs.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update :
                configureCell(tableGigs.cellForRowAtIndexPath(indexPath!) as? SeenGigTableViewCell, indexPath: indexPath!)
            case .Move :
                tableGigs.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableGigs.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableGigs.endUpdates()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // class functions
    //
    
    func coreDataObserver(coreDataObserver : CoreDataObserver, didChange object : NSManagedObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.setBandimage()
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func setUIFields() {
        pageTitle.title         = band.name
        
        do {
            let font = UIFont(name: "Lato", size: 10)!
            let bio = "<style type='text/css'>"
                + " html { "
                + "    line-height:80%; "
                + "    font-family: \(font.familyName);"
                + "    font-size: \(font.pointSize)px; }"
                + "</style>"
                + band.biography
            
            let text = try NSMutableAttributedString(  data: bio.dataUsingEncoding(NSUTF8StringEncoding)!,
                options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil);
            biography.scrollEnabled = false
            biography.attributedText = text
        } catch {
            biography.text = ""
        }
        ratingControl.rating    = band.avgRating.floatValue
        
        setGigTitle()
        setBandimage()
    }
    
    private func setGigTitle() {
        if band.gigs.count > 1 {
            gigTitle.text = String(format: NSLocalizedString("conGigListTitleMultiple", comment: "You have been to %0$d gigs:"), arguments: [band.gigs.count])
        } else if band.gigs.count == 1 {
            gigTitle.text = NSLocalizedString("conGigListTitleOne", comment: "You have been to one gig :")
        } else {
            gigTitle.text = NSLocalizedString("conGigListTitleNone", comment: "You have not been to any gigs yet.")
        }
    }
    
    private func setBandimage() {
        UrlFetcher.loadImageFromUrl(band.getImageUrl()) { image in
            self.imageIndicator.stopAnimating()
            self.bandImage.image = image
        }
    }
}