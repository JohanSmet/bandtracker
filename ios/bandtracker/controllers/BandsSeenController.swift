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
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in 
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Band")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "avgRating", ascending:false), NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController (
                                            fetchRequest: fetchRequest,
                                            managedObjectContext: coreDataStackManager().managedObjectContext!,
                                            sectionNameKeyPath: nil,
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
        keyboardFix = KeyboardFix(viewController: self)
        updateSearchResults("")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // handle keyboard properly
        if let keyboardFix = self.keyboardFix {
            keyboardFix.activate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let keyboardFix = self.keyboardFix {
            keyboardFix.deactivate()
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeenBandCell", for: indexPath) as! SeenBandTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    fileprivate func configureCell(_ cell : SeenBandTableViewCell?, indexPath : IndexPath) {
        
        guard let cell = cell else { return }
        guard let band = fetchedResultsController.object(at: indexPath) as? Band else { return }
        
        cell.bandName.text          = band.name
        cell.numberOfGigs.text      = String(format: NSLocalizedString("conGigCount", comment: "(%0$d gigs)"), arguments: [band.gigs.count])
        cell.ratingControl.rating   = band.avgRating.floatValue
        cell.bandImage.image        = nil
        cell.bandLogo.image         = nil
        
        UrlFetcher.loadImageFromUrl(band.getImageUrl()) { image in
            cell.bandImage.image = image
        }
        
        UrlFetcher.loadImageFromUrl(band.fanartLogoUrl ?? "") { image in
            cell.bandLogo.image = image
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let band = fetchedResultsController.object(at: indexPath) as! Band
            dataContext().deleteBand(band)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVc = BandDetailsController.create(fetchedResultsController.object(at: indexPath) as! Band)
        self.navigationController?.show(detailVc, sender: self)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // NSFetchedResultsControllerDelegate
    //
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
            case .insert :
                if indexPath == nil {               // Swift 2.0 BUG with running 8.4
                    tableView.insertRows(at: [newIndexPath!], with: .fade)
                }
            case .delete :
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update :
                configureCell(tableView.cellForRow(at: indexPath!) as? SeenBandTableViewCell, indexPath: indexPath!)
            case .move :
                if indexPath != newIndexPath {      // potential iOS 9 swift 2.0 with running 8.4
                    tableView.deleteRows(at: [indexPath!], with: .fade)
                    tableView.insertRows(at: [newIndexPath!], with: .fade)
                } else {
                    configureCell(tableView.cellForRow(at: indexPath!) as? SeenBandTableViewCell, indexPath: indexPath!)
                }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // MainTabSheet
    //
    
    func updateSearchResults(_ searchText : String) {
        
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
        self.performSegue(withIdentifier: "bandSearchSegue", sender: self)
    }
        
    var searchBarVisible : Bool { return true }
    var addButtonVisible : Bool { return true }
}
