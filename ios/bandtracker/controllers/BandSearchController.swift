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
    var bandList : [ServerBand] = []
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var tableBands: UITableView!
    
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
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UISearchResultsUpdating
    //
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        bandTrackerClient().bandsFindByName(searchController.searchBar.text!) { bands, error in
            if let bands = bands {
                self.bandList = bands
            } else {
                self.bandList.removeAll()
            }
            
            self.tableBands.reloadData()
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bandList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchBandCell")!
        
        // set the cell data
        let band = bandList[indexPath.row]
        cell.textLabel?.text = band.name
        
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // add the band to core data
        let band = bandList[indexPath.row]
        dataContext().createBand(band)
        
        // go to the detail page of the selected band
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}