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
   
    fileprivate var band             : Band!
    fileprivate var years            : [Int] = []
    fileprivate var filterController : GigGuidedCreationFilterController!
    fileprivate var tourDates        : [BandTrackerClient.TourDate] = []
    fileprivate var lastTimeStamp    : TimeInterval = 0
    
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
    
    class func create(_ band : Band, tourDateYears : [Int]) -> GigGuidedCreationController {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewController(withIdentifier: "GigGuidedCreationController") as! GigGuidedCreationController
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        filterContainerHeight.constant = filterController.tableView.contentSize.height + 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueEmbedGuidedFilter" {
            filterController = segue.destination as! GigGuidedCreationFilterController
            filterController.band  = band
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
    
    func filterValueChanged(_ filterController: GigGuidedCreationFilterController) {
        refreshData()
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDatasource
    //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        TableViewUtils.messageEmptyTable(tableView, isEmpty: self.tourDates.isEmpty, message: NSLocalizedString("conNoResults", comment: "No Results"))
        
        return self.tourDates.isEmpty ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tourDates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell     = tableView.dequeueReusableCell(withIdentifier: "GigGuidedCreationCell", for: indexPath) as! GigGuidedCreationCell
        let tourDate = tourDates[indexPath.row]
        
        cell.dateLabel.text = DateUtils.toDateStringMedium(tourDate.startDate)
        cell.setLocation(tourDate)
        
        return cell
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                                            location: nil) { tourDates, error, timestamp in
                                                
            // do not process results of older request than are currently on the screen
            if timestamp < self.lastTimeStamp {
                return
            }
            
            self.lastTimeStamp = timestamp
                                                
            var newTourDates : [BandTrackerClient.TourDate] = []
                                                
            if let tourDates = tourDates {
                for tourDate in tourDates {
                    if !dataContext().gigTourDatePresent(self.band, tourDate: tourDate) {
                        newTourDates.append(tourDate)
                    }
                }
            }
                                                
            DispatchQueue.main.async {
                self.tourDates = newTourDates
                self.tableView.reloadData()
            }
        }
    }
}
