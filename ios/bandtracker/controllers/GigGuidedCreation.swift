//
//  GigGuidedCreation.swift
//  bandtracker
//
//  Created by Johan Smet on 29/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class GigGuidedCreationController : UIViewController,
                                    UITableViewDataSource,
                                    UITableViewDelegate,
                                    GigGuidedCreationFilterDelegate {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
   
    private var band             : Band!
    private var years            : [Int] = []
    private var filterController : GigGuidedCreationFilterController!
    private var tourDates        : [BandTrackerClient.TourDate] = []
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var filterContainer: UIView!
    @IBOutlet weak var filterContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // class functions
    //
    
    class func create(band : Band, tourDateYears : [Int]) -> GigGuidedCreationController {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewControllerWithIdentifier("GigGuidedCreationController") as! GigGuidedCreationController
        newVC.band  = band
        newVC.years = tourDateYears
        return newVC
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup delegates
        tableView.dataSource = self
        tableView.delegate   = self
        filterController.delegate = self
        
        refreshData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        filterContainerHeight.constant = filterController.tableView.contentSize.height + 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueEmbedGuidedFilter" {
            filterController = segue.destinationViewController as! GigGuidedCreationFilterController
            filterController.years = years
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func createGigManually() {
        let newVC = GigDetailsController.createNewGig(band!)
        NavigationUtils.replaceViewController(navigationController!, newViewController: newVC)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // GigGuidedCreationFilterDelegate
    //
    
    func filterValueChanged(filterController: GigGuidedCreationFilterController) {
        refreshData()
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDatasource
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tourDates.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell     = tableView.dequeueReusableCellWithIdentifier("GigGuidedCreationCell", forIndexPath: indexPath) as! GigGuidedCreationCell
        let tourDate = tourDates[indexPath.row]
        
        cell.dateLabel.text = DateUtils.toDateStringMedium(tourDate.startDate)
        cell.setLocation(tourDate)
        
        return cell
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newVC = GigDetailsController.createNewGig(band!, tourDate: tourDates[indexPath.row])
        NavigationUtils.replaceViewController(navigationController!, newViewController: newVC)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    func refreshData() {
        bandTrackerClient().tourDateFind(   band.bandMBID,
                                            dateFrom: filterController.startDate, dateTo: filterController.endDate,
                                            countryCode: (filterController.country != nil) ? filterController.country.code : nil,
                                            location: nil) { tourDates, error in
            if let tourDates = tourDates {
                self.tourDates = tourDates
            }
                                                
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
}