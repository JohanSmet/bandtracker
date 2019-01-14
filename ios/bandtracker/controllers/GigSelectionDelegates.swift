//
//  GigSelectionDelegates.swift
//  bandtracker
//
//  Created by Johan Smet on 27/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class CountrySelectionDelegate : ListSelectionControllerDelegate {
    
    let enableFilter        : Bool   = true
    let enableCustomValue   : Bool   = false
    let filterPlaceHolder   : String = NSLocalizedString("conCountryPlaceholder", comment: "Enter country")
    let cellType            : String = "SelectionCellImage"
    let filterInitialValue  : String
    let completionHandler   : (_ name : String) -> Void
    
    init (initialFilter : String, completionHandler : @escaping (_ name : String) -> Void) {
        self.filterInitialValue = initialFilter
        self.completionHandler  = completionHandler
    }
    
    func numberOfSections(_ listSelectionController : ListSelectionController) -> Int {
        return 2
    }
    
    func titleForSection(_ listSelectionController : ListSelectionController, section : Int) -> String? {
        if section == 1 {
            return NSLocalizedString("conCountryPopular", comment: "Most popular countries")
        }
        return nil
    }
    
    func dataForSection(_ listSelectionController : ListSelectionController, section : Int, filterText : String, completionHandler : @escaping (_ data: [AnyObject]?) -> Void) {
        if filterText.isEmpty && section != 1 {
            return completionHandler(nil)
        }
        
        switch (section) {
            case 0 :
                completionHandler(dataContext().countryList(filterText))
            case 1 :
                completionHandler(dataContext().gigsTop5Countries())
            default :
                completionHandler(nil)
        }
    }
    
    func configureCellForItem(_ listSelectionController : ListSelectionController, cell : UITableViewCell, section : Int, item : AnyObject) {
        guard let country = item as? Country else { return }
        guard let imgCell = cell as? SelectionImageTableViewCell else { return }
        imgCell.title!.text = country.name
        
        if let flag = country.flag {
            imgCell.img!.image = UIImage(data: flag as Data)
        }
    }
    
    
    func didSelectItem(_ listSelectionController : ListSelectionController, custom : Bool, section : Int, item : AnyObject) {
        if let country = item as? Country {
            completionHandler(country.name)
        }
    }
}

class CitySelectionDelegate : ListSelectionControllerDelegate {
   
    
    let enableFilter        : Bool   = true
    let enableCustomValue   : Bool   = true
    let filterPlaceHolder   : String = NSLocalizedString("conCityPlaceholder", comment: "Enter city")
    let cellType            : String = "SelectionCellBasic"
    let filterInitialValue  : String
    let countryCode         : String?
    let completionHandler   : (_ name : String) -> Void
    var lastTimeStamp       : TimeInterval = 0
    
    init (initialFilter : String, countryCode: String?, completionHandler : @escaping (_ name : String) -> Void) {
        self.filterInitialValue = initialFilter
        self.countryCode        = countryCode
        self.completionHandler  = completionHandler
    }
    
    func numberOfSections(_ listSelectionController : ListSelectionController) -> Int {
        return 2
    }
    
    func titleForSection(_ listSelectionController : ListSelectionController, section : Int) -> String? {
        switch (section) {
            case 0 : return NSLocalizedString("conResultsPrevious", comment: "Previously used")
            case 1 : return NSLocalizedString("conResultsNew", comment: "New")
            default : return nil
        }
    
    }
    
    func dataForSection(_ listSelectionController: ListSelectionController, section: Int, filterText: String, completionHandler: @escaping ([AnyObject]?) -> Void) {
        
        if filterText.isEmpty {
            return completionHandler(nil)
        }
        
        switch (section) {
        case 0 :
            completionHandler(dataContext().cityList(filterText))
        case 1 :
            bandTrackerClient().cityFind(filterText, countryCode: countryCode) { cities, error, timestamp in
                // do not process results of older request than are currently on the screen
                if timestamp < self.lastTimeStamp {
                    return
                }
                
                self.lastTimeStamp = timestamp
                
                completionHandler(cities as! [AnyObject])
            }
        default :
            completionHandler(nil)
        }
    }
    
    func configureCellForItem(_ listSelectionController : ListSelectionController, cell : UITableViewCell, section : Int, item : AnyObject) {
        if let city = item as? City {
            cell.textLabel?.text =  city.name
        } else if let city = item as? String {
            cell.textLabel?.text =  city
        } else {
            cell.textLabel?.text =  ""
        }
    }
    
    func didSelectItem(_ listSelectionController : ListSelectionController, custom : Bool, section : Int, item : AnyObject) {
        if let city = item as? City {
            completionHandler(city.name)
        } else if let city = item as? String {
            completionHandler(city)
        }
    }
}


class VenueSelectionDelegate : ListSelectionControllerDelegate {
    
    let enableFilter        : Bool   = true
    let enableCustomValue   : Bool   = true
    let filterPlaceHolder   : String = NSLocalizedString("conVenuePlaceholder", comment: "Enter venue")
    let cellType            : String = "SelectionCellBasic"
    let filterInitialValue  : String
    let countryCode         : String?
    let city                : String?
    let completionHandler   : (_ name : String) -> Void
    var lastTimeStamp       : TimeInterval = 0
    
    init (initialFilter : String, countryCode: String?, city : String?, completionHandler : @escaping (_ name : String) -> Void) {
        self.filterInitialValue = initialFilter
        self.countryCode        = countryCode
        self.city               = city
        self.completionHandler  = completionHandler
    }
    
    func numberOfSections(_ listSelectionController : ListSelectionController) -> Int {
        return 2
    }
    
    func titleForSection(_ listSelectionController : ListSelectionController, section : Int) -> String? {
        switch (section) {
            case 0 : return NSLocalizedString("conResultsPrevious", comment: "Previously used")
            case 1 : return NSLocalizedString("conResultsNew", comment: "New")
            default : return nil
        }
    }
    
    func dataForSection(_ listSelectionController : ListSelectionController, section : Int, filterText : String, completionHandler : @escaping ([AnyObject]?) -> Void) {
        
        if filterText.isEmpty {
            return completionHandler(nil)
        }
        
        switch (section) {
        case 0 :
            completionHandler(dataContext().venueList(filterText))
        case 1 :
            bandTrackerClient().venueFind(filterText, countryCode: countryCode, city : city) { venue, error, timestamp in
                // do not process results of older request than are currently on the screen
                if timestamp < self.lastTimeStamp {
                    return
                }
                
                self.lastTimeStamp = timestamp
                completionHandler(venue as! [AnyObject])
            }
        default :
            completionHandler(nil)
        }
    }
    
    func configureCellForItem(_ listSelectionController : ListSelectionController, cell : UITableViewCell, section : Int, item : AnyObject) {
        if let venue = item as? Venue {
            cell.textLabel?.text = venue.name
        } else if let venue = item as? String {
            cell.textLabel?.text = venue
        } else {
            cell.textLabel?.text = ""
        }
    }
    
    func didSelectItem(_ listSelectionController : ListSelectionController, custom : Bool, section : Int, item : AnyObject) {
        if let venue = item as? Venue {
            completionHandler(venue.name)
        } else if let venue = item as? String {
            completionHandler(venue)
        }
    }
}
