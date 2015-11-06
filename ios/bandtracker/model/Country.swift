//
//  Country.swift
//  bandtracker
//
//  Created by Johan Smet on 03/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

@objc(Country)

class Country : NSManagedObject {
    
    @NSManaged var code         : String
    @NSManaged var name         : String
    @NSManaged var flag         : NSData!
    
    @NSManaged var gigs         : [Gig]
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(code : String, name : String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Country", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // properties
        self.code = code
        self.name = name
    }
}