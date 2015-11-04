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
    
    var searchController : UISearchController! = nil
    
    var newBandList      : [ServerBand] = []
    var existingBandList : [Band] = []
    
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
            tableView.reloadData()
            return
        }
        
        // search online
        bandTrackerClient().bandsFindByName(searchText) { bands, error in
            
            self.existingBandList = dataContext().bandList(searchText)
            
            if let bands = bands {
                self.newBandList = bands.filter { (newBand) in
                    return !self.existingBandList.contains({existingBand in newBand.MBID == existingBand.bandMBID})
                }
                
            } else {
                self.newBandList.removeAll()
            }
           
            dispatch_sync(dispatch_get_main_queue()) {
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
            return "Already added bands"
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
        // add the band to core data (if it's a new one)
        if indexPath.section == 0 {
            let band = newBandList[indexPath.row]
            dataContext().createBand(band)
        }
        
        // go to the detail page of the selected band
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}