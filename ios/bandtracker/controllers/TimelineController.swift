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
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in 
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gig")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath)  as! TimelineTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let theSection = self.fetchedResultsController.sections![section]
        let firstGig = theSection.objects![0] as! Gig
        return "\(firstGig.year)"
    }
    
    fileprivate func configureCell(_ cell : TimelineTableViewCell?, indexPath : IndexPath) {
        guard let cell = cell else { return }
        guard let gig = fetchedResultsController.object(at: indexPath) as? Gig else { return }
        cell.setFields(gig)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let gig     = fetchedResultsController.object(at: indexPath) as! Gig
        let newVC   = GigDetailsController.displayGig(gig)
        navigationController?.pushViewController(newVC, animated: true)
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
                if indexPath == nil {       // Swift 2.0 BUG with running 8.4
                    tableView.insertRows(at: [newIndexPath!], with: .fade)
                }
            case .delete :
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update :
                configureCell(tableView.cellForRow(at: indexPath!) as? TimelineTableViewCell, indexPath: indexPath!)
            case .move :
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch (type) {
            case .insert :
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete :
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                let _ = false
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
        if !searchText.isEmpty {
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
