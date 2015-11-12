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
    let completionHandler   : (name : String) -> Void
    
    init (initialFilter : String, completionHandler : (name : String) -> Void) {
        self.filterInitialValue = initialFilter
        self.completionHandler  = completionHandler
    }
    
    func numberOfSections(listSelectionController : ListSelectionController) -> Int {
        return 2
    }
    
    func titleForSection(listSelectionController : ListSelectionController, section : Int) -> String? {
        if section == 1 {
            return NSLocalizedString("conCountryPopular", comment: "Most popular countries")
        }
        return nil
    }
    
    func dataForSection(listSelectionController : ListSelectionController, section : Int, filterText : String, completionHandler : (data: [AnyObject]?) -> Void) {
        if filterText.isEmpty && section != 1 {
            return completionHandler(data: nil)
        }
        
        switch (section) {
            case 0 :
                completionHandler(data: dataContext().countryList(filterText))
            case 1 :
                completionHandler(data: dataContext().gigsTop5Countries())
            default :
                completionHandler(data: nil)
        }
    }
    
    func configureCellForItem(listSelectionController : ListSelectionController, cell : UITableViewCell, section : Int, item : AnyObject) {
        guard let country = item as? Country else { return }
        guard let imgCell = cell as? SelectionImageTableViewCell else { return }
        imgCell.title!.text = country.name
        
        if let flag = country.flag {
            imgCell.img!.image = UIImage(data: flag)
        }
    }
    
    
    func didSelectItem(listSelectionController : ListSelectionController, custom : Bool, section : Int, item : AnyObject) {
        if let country = item as? Country {
            completionHandler(name: country.name)
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
    let completionHandler   : (name : String) -> Void
    
    init (initialFilter : String, countryCode: String?, completionHandler : (name : String) -> Void) {
        self.filterInitialValue = initialFilter
        self.countryCode        = countryCode
        self.completionHandler  = completionHandler
    }
    
    func numberOfSections(listSelectionController : ListSelectionController) -> Int {
        return 2
    }
    
    func titleForSection(listSelectionController : ListSelectionController, section : Int) -> String? {
        switch (section) {
            case 0 : return NSLocalizedString("conResultsPrevious", comment: "Previously used")
            case 1 : return NSLocalizedString("conResultsNew", comment: "New")
            default : return nil
        }
    }
    
    func dataForSection(listSelectionController : ListSelectionController, section : Int, filterText : String, completionHandler : (data: [AnyObject]?) -> Void) {
        
        if filterText.isEmpty {
            return completionHandler(data: nil)
        }
        
        switch (section) {
        case 0 :
            completionHandler(data: dataContext().cityList(filterText))
        case 1 :
            bandTrackerClient().cityFind(filterText, countryCode: countryCode) { cities, error in
                completionHandler(data: cities)
            }
        default :
            completionHandler(data: nil)
        }
    }
    
    func configureCellForItem(listSelectionController : ListSelectionController, cell : UITableViewCell, section : Int, item : AnyObject) {
        if let city = item as? City {
            cell.textLabel?.text =  city.name
        } else if let city = item as? String {
            cell.textLabel?.text =  city
        } else {
            cell.textLabel?.text =  ""
        }
    }
    
    func didSelectItem(listSelectionController : ListSelectionController, custom : Bool, section : Int, item : AnyObject) {
        if let city = item as? City {
            completionHandler(name: city.name)
        } else if let city = item as? String {
            completionHandler(name: city)
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
    let completionHandler   : (name : String) -> Void
    
    init (initialFilter : String, countryCode: String?, city : String?, completionHandler : (name : String) -> Void) {
        self.filterInitialValue = initialFilter
        self.countryCode        = countryCode
        self.city               = city
        self.completionHandler  = completionHandler
    }
    
    func numberOfSections(listSelectionController : ListSelectionController) -> Int {
        return 2
    }
    
    func titleForSection(listSelectionController : ListSelectionController, section : Int) -> String? {
        switch (section) {
            case 0 : return NSLocalizedString("conResultsPrevious", comment: "Previously used")
            case 1 : return NSLocalizedString("conResultsNew", comment: "New")
            default : return nil
        }
    }
    
    func dataForSection(listSelectionController : ListSelectionController, section : Int, filterText : String, completionHandler : (data: [AnyObject]?) -> Void) {
        
        if filterText.isEmpty {
            return completionHandler(data: nil)
        }
        
        switch (section) {
        case 0 :
            completionHandler(data: dataContext().venueList(filterText))
        case 1 :
            bandTrackerClient().venueFind(filterText, countryCode: countryCode, city : city) { venue, error in
                completionHandler(data: venue)
            }
        default :
            completionHandler(data: nil)
        }
    }
    
    func configureCellForItem(listSelectionController : ListSelectionController, cell : UITableViewCell, section : Int, item : AnyObject) {
        if let venue = item as? Venue {
            cell.textLabel?.text = venue.name
        } else if let venue = item as? String {
            cell.textLabel?.text = venue
        } else {
            cell.textLabel?.text = ""
        }
    }
    
    func didSelectItem(listSelectionController : ListSelectionController, custom : Bool, section : Int, item : AnyObject) {
        if let venue = item as? Venue {
            completionHandler(name: venue.name)
        } else if let venue = item as? String {
            completionHandler(name: venue)
        }
    }
}