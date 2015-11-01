//
//  GigSelectionDelegates.swift
//  bandtracker
//
//  Created by Johan Smet on 27/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

class CountrySelectionDelegate : ListSelectionControllerDelegate {
    
    let enableFilter        : Bool   = true
    let enableCustomValue   : Bool   = false
    let filterPlaceHolder   : String = "Enter country"
    let filterInitialValue  : String
    let completionHandler   : (name : String) -> Void
    
    init (initialFilter : String, completionHandler : (name : String) -> Void) {
        self.filterInitialValue = initialFilter
        self.completionHandler  = completionHandler
    }
    
    func numberOfSections(listSelectionController : ListSelectionController) -> Int {
        return 1
    }
    
    func titleForSection(listSelectionController : ListSelectionController, section : Int) -> String? {
        return nil
    }
    
    func dataForSection(listSelectionController : ListSelectionController, section : Int, filterText : String, completionHandler : (data: [AnyObject]?) -> Void) {
        completionHandler(data: dataContext().countryList(filterText))
    }
    
    func labelForItem(listSelectionController : ListSelectionController, section : Int, item : AnyObject) -> String {
        return (item as? Country)!.name
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
    let filterPlaceHolder   : String = "Enter city"
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
        case 0 : return "Previously used"
        case 1 : return "New"
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
    
    func labelForItem(listSelectionController : ListSelectionController, section : Int, item : AnyObject) -> String {
        if let city = item as? City {
            return city.name
        } else if let city = item as? String {
            return city
        } else {
            return ""
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
    let filterPlaceHolder   : String = "Enter venue"
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
        case 0 : return "Previously used"
        case 1 : return "New"
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
    
    func labelForItem(listSelectionController : ListSelectionController, section : Int, item : AnyObject) -> String {
        if let venue = item as? Venue {
            return venue.name
        } else if let venue = item as? String {
            return venue
        } else {
            return ""
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