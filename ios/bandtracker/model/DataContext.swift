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
    // gig management
    //
    
    func createPartialGig(band : Band) -> Gig {
        return Gig(band: band, context: coreDataStackManager().managedObjectContext!)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // country
    //
    
    func countryByName(countryName : String) -> Country {
        
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate  = NSPredicate(format: "name == %@", countryName)
        
        do {
            let results = try coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest) as! [Country]
           
            if results.count > 0 {
                return results[0]
            }
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // create a new record (XXX this makes no sense ...)
        let country = Country(code: countryName, name: countryName, context: coreDataStackManager().managedObjectContext!)
        return country
    }
    
    func cityByName(cityName : String) -> City? {
        
        if cityName.characters.count <= 0 {
            return nil
        }
        
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest(entityName: "City")
        fetchRequest.predicate  = NSPredicate(format: "name == %@", cityName)
        
        do {
            let results = try coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest) as! [City]
            
            if results.count > 0 {
                return results[0]
            }
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // create a new record
        return City(name: cityName, longitude: 0, latitude: 0, context: coreDataStackManager().managedObjectContext!)
    }
    
    func venueByName(venueName : String) -> Venue? {
        
        if venueName.characters.count <= 0 {
            return nil
        }
        
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest(entityName: "Venue")
        fetchRequest.predicate  = NSPredicate(format: "name == %@", venueName)
        
        do {
            let results = try coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest) as! [Venue]
            
            if results.count > 0 {
                return results[0]
            }
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // create a new record
        return Venue(name: venueName, longitude: 0, latitude: 0, context: coreDataStackManager().managedObjectContext!)
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