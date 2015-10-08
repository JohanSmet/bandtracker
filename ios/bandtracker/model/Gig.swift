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
    
    @NSManaged var startDate    : NSDate
    @NSManaged var endDate      : NSDate
    @NSManaged var stage        : String
    @NSManaged var supportAct   : Bool
    @NSManaged var rating       : NSNumber
    @NSManaged var comments     : String
    
    @NSManaged var band         : Band
    @NSManaged var country      : Country
    @NSManaged var city         : City?
    @NSManaged var venue        : Venue?
    
    var editCountry             : String = ""
    var editCity                : String = ""
    var editVenue               : String = ""
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(band : Band, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Gig", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // properties
        self.startDate  = DateUtils.currentTimeRoundMinutes(15)
        self.endDate    = self.startDate
        self.band = band
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
        country = dataContext().countryByName(editCountry)
        city    = dataContext().cityByName(editCity)
        venue   = dataContext().venueByName(editVenue)
    }
    
}