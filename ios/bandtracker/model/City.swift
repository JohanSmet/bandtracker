//
//  City.swift
//  bandtracker
//
//  Created by Johan Smet on 03/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

@objc(City)

class City : NSManagedObject {
    
    @NSManaged var name         : String
    @NSManaged var longitude    : NSNumber
    @NSManaged var latitude     : NSNumber
    
    @NSManaged var gigs         : [Gig]
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(name : String, longitude : Double, latitude : Double, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "City", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // properties
        self.name       = name
        self.longitude  = NSNumber(value: longitude)
        self.latitude   = NSNumber(value: latitude)
    }
}
