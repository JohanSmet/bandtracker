//
//  DataContext.swift
//  BandTracker
//
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

class DataContext {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // band management
    //
    
    func createBand(bandTemplate : ServerBand) -> Band {
        // create band
        let band = Band(bandTemplate: bandTemplate, context: coreDataStackManager().managedObjectContext!)
        
        // save all changes
        coreDataStackManager().saveContext()
        
        return band
    }
    
    func deleteBand(band : Band) {
        coreDataStackManager().managedObjectContext?.deleteObject(band)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //
    
    static let sharedInstance = DataContext()
}

func dataContext() -> DataContext {
    return DataContext.sharedInstance
}