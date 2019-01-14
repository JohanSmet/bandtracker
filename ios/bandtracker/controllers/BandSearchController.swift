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
    
    let SECTION_NEW  = 1
    let SECTION_OLD  = 2
    
    fileprivate var searchController : UISearchController! = nil
    
    fileprivate var lastTimeStamp    : TimeInterval = 0
    fileprivate var lastSearchText   : String = ""
    fileprivate var lastBandList     : [BandTrackerClient.Band] = []
    
    fileprivate var sections         : [Int] = [0, 0]
    fileprivate var newBandList      : [BandTrackerClient.Band] = []
    fileprivate var existingBandList : [Band] = []
    fileprivate var error            : String = ""
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // dismiss the search controller (to prevent "already presenting" errors next time)
        searchController.isActive = false
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UISearchResultsUpdating
    //
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        
        // check minimum length of the search pattern
        if searchText.characters.count < 2 {
            existingBandList.removeAll()
            newBandList.removeAll()
            lastBandList.removeAll()
            lastTimeStamp = Date.timeIntervalSinceReferenceDate
            lastSearchText = ""
            tableView.reloadData()
            return
        }
        
        // no need to search online when the new search pattern is the old pattern with an appended suffix
        if lastSearchText.characters.count >= 2 && searchText.hasPrefix(lastSearchText) {
            
            existingBandList = dataContext().bandList(searchText)
            localFilterNewBands(searchText)
            
            lastTimeStamp  = Date.timeIntervalSinceReferenceDate
            tableView.reloadData()
            return
        }
        
        // search online
        bandTrackerClient().bandsFindByName(searchText) { bands, error, timestamp in
            
            // do not process results of older request than are currently on the screen
            if timestamp < self.lastTimeStamp {
                return
            }
            
            
            if let error = error {
                DispatchQueue.main.async {
                    self.error = error
                    self.existingBandList.removeAll()
                    self.newBandList.removeAll()
                    self.tableView.reloadData()
                }
                return
            }
           
            // do not update the class variables from this thread to avoid race conditions
            let existingBands = dataContext().bandList(searchText)
            let newBands : [BandTrackerClient.Band]!
            
            if let bands = bands {
                newBands = bands.filter { (newBand) in
                    return !existingBands.contains(where: {existingBand in newBand.MBID == existingBand.bandMBID})
                }
                
            } else {
                newBands = []
            }
           
            DispatchQueue.main.async {
                self.error            = ""
                self.lastTimeStamp    = timestamp
                self.lastSearchText   = searchText
                
                self.existingBandList = existingBands
                self.lastBandList     = newBands
                self.localFilterNewBands(searchText)
                
                self.tableView.reloadData()
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        
        if !self.newBandList.isEmpty {
            self.sections[count] = SECTION_NEW
            count = count + 1
        }
        
        if !self.existingBandList.isEmpty {
            self.sections[count] = SECTION_OLD
            count = count + 1
        }
        
        if error.isEmpty {
            TableViewUtils.messageEmptyTable(tableView, isEmpty: count == 0 && !lastSearchText.isEmpty, message: NSLocalizedString("conNoResults", comment: "No Results"))
        } else {
            TableViewUtils.messageEmptyTable(tableView, isEmpty: true, message: error)
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections[section] == SECTION_OLD {
            return NSLocalizedString("conAlreadyAddedBands", comment: "Already added bands")
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section] == SECTION_NEW {
            return self.newBandList.count
        } else {
            return self.existingBandList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBandCell")!
        
        // indexPath should not go out of range (anymore - earlier versions had a race condition), but just be safe
        guard validIndexPath(indexPath) else  { return cell }
        
        // set the cell data
        if sections[indexPath.section] == SECTION_NEW {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let band : Band!
        
        // add the band to core data (if it's a new one)
        if sections[indexPath.section] == SECTION_NEW {
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
    
    fileprivate func validIndexPath(_ indexPath : IndexPath) -> Bool {
        
        // valid section ?
        if indexPath.section < 0 || indexPath.section > 1 {
            return false
        }
        
        // valid row ?
        let size = (sections[indexPath.section] == SECTION_NEW) ? newBandList.count : existingBandList.count
        
        if indexPath.row < 0 || indexPath.row >= size {
            return false
        }
        
        return true
    }
    
    fileprivate func localFilterNewBands(_ filterText : String) {
        let lcSearchText = filterText.lowercased()
        newBandList = lastBandList.filter() { $0.name.lowercased().contains(lcSearchText)}
    }
    
}
