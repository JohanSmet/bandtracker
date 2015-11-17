//
//  BandSearchController.swift
//  bandtracker
//
//  Created by Johan Smet on 22/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class BandSearchController: UITableViewController,
                            UISearchResultsUpdating {

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private var searchController : UISearchController! = nil
    
    private var lastTimeStamp    : NSTimeInterval = 0
    private var lastSearchText   : String = ""
    
    private var newBandList      : [BandTrackerClient.Band] = []
    private var existingBandList : [Band] = []
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // dismiss the search controller (to prevent "already presenting" errors next time)
        searchController.active = false
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UISearchResultsUpdating
    //
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        
        // check minimum length of the search pattern
        if searchText.characters.count < 2 {
            existingBandList.removeAll()
            newBandList.removeAll()
            lastTimeStamp = NSDate.timeIntervalSinceReferenceDate()
            tableView.reloadData()
            return
        }
        
        // no need to search online when the new search pattern is the old pattern with an appended suffix
        if lastSearchText.characters.count >= 2 && searchText.hasPrefix(lastSearchText) {
            let lcSearchText = searchText.lowercaseString
            
            existingBandList = existingBandList.filter() { $0.name.lowercaseString.containsString(lcSearchText)}
            newBandList = newBandList.filter() { $0.name.lowercaseString.containsString(lcSearchText)}
            
            lastSearchText = searchText
            lastTimeStamp  = NSDate.timeIntervalSinceReferenceDate()
            tableView.reloadData()
            return
        }
        
        // search online
        bandTrackerClient().bandsFindByName(searchText) { bands, error, timestamp in
            
            // do not process results of older request than are currently on the screen
            if timestamp < self.lastTimeStamp {
                return
            }
            
            self.lastTimeStamp = timestamp
           
            // do not update the class variables from this thread to avoid race conditions
            let existingBands = dataContext().bandList(searchText)
            let newBands : [BandTrackerClient.Band]!
            
            if let bands = bands {
                newBands = bands.filter { (newBand) in
                    return !existingBands.contains({existingBand in newBand.MBID == existingBand.bandMBID})
                }
                
            } else {
                newBands = []
            }
           
            dispatch_async(dispatch_get_main_queue()) {
                self.lastSearchText   = searchText
                self.existingBandList = existingBands
                self.newBandList      = newBands
                self.tableView.reloadData()
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.existingBandList.count > 0 ? 2 : 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("conAlreadyAddedBands", comment: "Already added bands")
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.newBandList.count
        } else {
            return self.existingBandList.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchBandCell")!
        
        // indexPath should go out of range (anymore - earlier versions had a race condition), but just be safe
        guard validIndexPath(indexPath) else  { return cell }
        
        // set the cell data
        if indexPath.section == 0 {
            cell.textLabel?.text = newBandList[indexPath.row].name
        } else {
            cell.textLabel?.text = existingBandList[indexPath.row].name
        }
        
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let band : Band!
        
        // add the band to core data (if it's a new one)
        if indexPath.section == 0 {
            let serverBand = newBandList[indexPath.row]
            band = dataContext().createBand(serverBand)
        } else {
            band = existingBandList[indexPath.row]
        }
        
        // go to the detail page of the selected band
        let newVC = BandDetailsController.create(band);
        NavigationUtils.replaceViewController(self.navigationController!, newViewController: newVC)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func validIndexPath(indexPath : NSIndexPath) -> Bool {
        
        // valid section ?
        if indexPath.section < 0 || indexPath.section > 1 {
            return false
        }
        
        // valid row ?
        let size = (indexPath.section == 0) ? newBandList.count : existingBandList.count
        
        if indexPath.row < 0 || indexPath.row >= size {
            return false
        }
        
        return true
    }
    
}