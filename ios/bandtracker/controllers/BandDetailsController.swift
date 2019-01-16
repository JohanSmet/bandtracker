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
    
    lazy var gigFetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in 
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gig")
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
    
    fileprivate var coreDataObserver : CoreDataObserver!
    
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
    
    class func create(_ band : Band) -> BandDetailsController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let newVc = storyboard.instantiateViewController(withIdentifier: "BandDetailsController") as! BandDetailsController
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the biography is shown from the start
        biography.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        coreDataObserver.startObservingObject(band)
        
        setGigTitle()
        setBandimage()
        ratingControl.rating    = band.avgRating.floatValue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coreDataObserver.stopObservingObject(band)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func addGig(_ sender: AnyObject) {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.gigFetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = gigFetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gigSeenCell", for: indexPath) as! SeenGigTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell : SeenGigTableViewCell?, indexPath : IndexPath) {
        guard let cell = cell else { return }
        guard let gig = gigFetchedResultsController.object(at: indexPath) as? Gig else { return }
        
        cell.setFields(gig)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let gig = gigFetchedResultsController.object(at: indexPath) as! Gig
        let newVC = GigDetailsController.displayGig(gig)
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let gig = gigFetchedResultsController.object(at: indexPath) as! Gig
            dataContext().deleteGig(gig)
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // NSFetchedResultsControllerDelegate
    //
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableGigs.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch (type) {
            case .insert :
                if indexPath == nil {       // Swift 2.0 BUG with running 8.4
                    tableGigs.insertRows(at: [newIndexPath!], with: .fade)
                }
            case .delete :
                tableGigs.deleteRows(at: [indexPath!], with: .fade)
            case .update :
                configureCell(tableGigs.cellForRow(at: indexPath!) as? SeenGigTableViewCell, indexPath: indexPath!)
            case .move :
                tableGigs.deleteRows(at: [indexPath!], with: .fade)
                tableGigs.insertRows(at: [newIndexPath!], with: .fade)
            }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableGigs.endUpdates()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // class functions
    //
    
    func coreDataObserver(_ coreDataObserver : CoreDataObserver, didChange object : NSManagedObject) {
        DispatchQueue.main.async {
            self.setBandimage()
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    fileprivate func setUIFields() {
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
            
            let text = try NSMutableAttributedString(  data: bio.data(using: String.Encoding.utf8)!,
                options: convertToNSAttributedStringDocumentReadingOptionKeyDictionary([convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.documentType): convertFromNSAttributedStringDocumentType(NSAttributedString.DocumentType.html)]),
                documentAttributes: nil);
            biography.attributedText = text
        } catch {
            biography.text = ""
        }
        ratingControl.rating    = band.avgRating.floatValue
        
        setGigTitle()
        setBandimage()
    }
    
    fileprivate func setGigTitle() {
        if band.gigs.count > 1 {
            gigTitle.text = String(format: NSLocalizedString("conGigListTitleMultiple", comment: "You have been to %0$d gigs:"), arguments: [band.gigs.count])
        } else if band.gigs.count == 1 {
            gigTitle.text = NSLocalizedString("conGigListTitleOne", comment: "You have been to one gig :")
        } else {
            gigTitle.text = NSLocalizedString("conGigListTitleNone", comment: "You have not been to any gigs yet.")
        }
    }
    
    fileprivate func setBandimage() {
        UrlFetcher.loadImageFromUrl(band.getImageUrl()) { image in
            self.imageIndicator.stopAnimating()
            self.bandImage.image = image
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringDocumentReadingOptionKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.DocumentReadingOptionKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.DocumentReadingOptionKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentAttributeKey(_ input: NSAttributedString.DocumentAttributeKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentType(_ input: NSAttributedString.DocumentType) -> String {
	return input.rawValue
}
