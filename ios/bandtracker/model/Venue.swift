//
//  Venue.swift
//  bandtracker
//
//  Created by Johan Smet on 03/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

@objc(Venue)

class Venue : NSManagedObject {
    
    @NSManaged var name         : String
    @NSManaged var longitude    : NSNumber
    @NSManaged var latitude     : NSNumber
    
    @NSManaged var gigs         : [Gig]
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(name : String, longitude : Double, latitude : Double, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Venue", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // properties
        self.name       = name
        self.longitude  = longitude
        self.latitude   = latitude
    }
}