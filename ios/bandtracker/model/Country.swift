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
    @NSManaged var flag         : Data!
    
    @NSManaged var gigs         : [Gig]
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(code : String, name : String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "Country", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // properties
        self.code = code
        self.name = name
    }
}
