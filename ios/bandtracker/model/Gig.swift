//
//  Gig.swift
//  bandtracker
//
//  Created by Johan Smet on 03/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

@objc(Gig)

class Gig : NSManagedObject {
    
    @NSManaged var startDate    : Date
    @NSManaged var endDate      : Date
    @NSManaged var stage        : String
    @NSManaged var supportAct   : Bool
    @NSManaged var rating       : NSNumber
    @NSManaged var comments     : String
    
    @NSManaged var band         : Band
    @NSManaged var country      : Country
    @NSManaged var city         : City?
    @NSManaged var venue        : Venue?
    
    var year : NSNumber {
        return NSNumber(value: (Calendar.current as NSCalendar).component(.year, from: startDate))
    }
    
    var editCountry             : String = ""
    var editCity                : String = ""
    var editVenue               : String = ""
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(band : Band, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "Gig", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // properties
        self.startDate  = DateUtils.currentTimeRoundMinutes(15)
        self.endDate    = self.startDate
        self.band = band
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // convience functions
    //
    
    func formatLocation() -> String {
        var location  : String = ""
        var separator : String = ""
        var venueSet  : Bool   = false
        
        if let venue = venue {
            location += separator + venue.name
            separator = ", "
            venueSet  = true
        }
        
        if let city = city {
            location += separator + city.name
            separator = ", "
        }
        
        if !venueSet {
            location += separator + country.name
        }
        
        return location
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // edit functions
    //
    
    func prepareForEdit () {
        editCountry = country.name
        editCity    = city?.name ?? ""
        editVenue   = venue?.name ?? ""
    }
    
    func processEdit() {
        country = dataContext().countryByName(editCountry, context: managedObjectContext!)
        city    = dataContext().cityByName(editCity, context: managedObjectContext!)
        venue   = dataContext().venueByName(editVenue, context: managedObjectContext!)
    }
    
}
