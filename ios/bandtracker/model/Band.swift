//
//  Band.swift
//  bandtracker
//
//  Created by Johan Smet on 25/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

@objc(Band)

class Band : NSManagedObject {
    
    @NSManaged var bandMBID     : String
    @NSManaged var name         : String
    @NSManaged var biography    : String
    @NSManaged var imageUrl     : String
    @NSManaged var numGigs      : NSNumber
    @NSManaged var totalRating  : NSNumber
    
    @NSManaged var gigs         : [Gig]
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(bandTemplate : ServerBand, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Band", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // properties
        bandMBID    = bandTemplate.MBID
        name        = bandTemplate.name
        biography   = bandTemplate.biography
        imageUrl    = bandTemplate.imageUrl
        numGigs     = 0
        totalRating = 0
    }
    
    func rating() -> Float {
       return totalRating.floatValue / (Float(gigs.count) * 10)
    }
}
