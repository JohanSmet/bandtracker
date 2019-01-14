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
    @NSManaged var numGigs      : NSNumber
    @NSManaged var totalRating  : NSNumber
    @NSManaged var avgRating    : NSNumber
    
    @NSManaged var imageUrl         : String
    @NSManaged var fanartThumbUrl   : String?
    @NSManaged var fanartLogoUrl    : String?
    
    @NSManaged var gigs         : [Gig]
    
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(bandTemplate : BandTrackerClient.Band, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "Band", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // properties
        bandMBID    = bandTemplate.MBID
        name        = bandTemplate.name
        biography   = bandTemplate.biography
        imageUrl    = bandTemplate.imageUrl
        numGigs     = 0
        totalRating = 0
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // convenience functions
    //
    
    func rating() -> Float {
        if !gigs.isEmpty {
            return round(totalRating.floatValue / (Float(gigs.count) * 10))
        } else {
            return 0
        }
    }
    
    func getImageUrl() -> String {
        // only use the fanart images
        if let thumb = fanartThumbUrl {
            return thumb
        }
        
        return ""
    }
}
