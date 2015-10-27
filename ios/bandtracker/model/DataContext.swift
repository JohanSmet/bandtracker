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
    
    func bandList(nameFilter : String) -> [Band] {
        let fetchRequest = NSFetchRequest(entityName: "Band")
        if nameFilter.characters.count > 0 {
            fetchRequest.predicate       = NSPredicate(format: "name CONTAINS[cd] %@", nameFilter)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest) as! [Band]
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return []
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // gig management
    //
    
    func totalRatingOfGigs(band : Band) -> Int {
        
        let sumExpDesc = NSExpressionDescription()
        sumExpDesc.name = "sumRating"
        sumExpDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "rating")])
        sumExpDesc.expressionResultType = .Integer32AttributeType
        
        let fetchRequest = NSFetchRequest(entityName: "Gig")
        fetchRequest.predicate      = NSPredicate(format: "band.bandMBID == %@", band.bandMBID)
        fetchRequest.resultType     = .DictionaryResultType
        fetchRequest.propertiesToFetch = [sumExpDesc]
        
        do {
            if let results = try coreDataStackManager().managedObjectContext?.executeFetchRequest(fetchRequest) {
                let dict = results[0] as! [String : Int]
                return dict["sumRating"]!
            }
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        return 0
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // country
    //
    
    func countryDictionary() -> [String : Country] {
        
        let fetchRequest = NSFetchRequest(entityName: "Country")
        var results : [String : Country] = [:]
        
        do {
            for country in try coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest) as! [Country] {
                results[country.code] = country
            }
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
            
        return results
    }
    
    func countryByName(countryName : String, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> Country {
        
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate  = NSPredicate(format: "name == %@", countryName)
        
        do {
            let results = try context.executeFetchRequest(fetchRequest) as! [Country]
           
            if results.count > 0 {
                return results[0]
            }
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // create a new record (XXX this makes no sense ...)
        let country = Country(code: countryName, name: countryName, context: context)
        return country
    }
    
    func countryList(nameFilter : String) -> [Country] {
        
        let fetchRequest = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate       = NSPredicate(format: "name CONTAINS[cd] %@", nameFilter)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest) as! [Country]
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return []
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // city
    //
    
    func cityByName(cityName : String, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> City? {
        
        if cityName.characters.count <= 0 {
            return nil
        }
        
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest(entityName: "City")
        fetchRequest.predicate  = NSPredicate(format: "name == %@", cityName)
        
        do {
            let results = try context.executeFetchRequest(fetchRequest) as! [City]
            
            if results.count > 0 {
                return results[0]
            }
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // create a new record
        return City(name: cityName, longitude: 0, latitude: 0, context: context)
    }
    
    func cityList(nameFilter : String) -> [City] {
        let fetchRequest        = NSFetchRequest(entityName: "City")
        fetchRequest.predicate  = NSPredicate(format: "name CONTAINS[cd] %@", nameFilter)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest) as! [City]
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return []
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // venue
    //
    
    func venueByName(venueName : String, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> Venue? {
        
        if venueName.characters.count <= 0 {
            return nil
        }
        
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest(entityName: "Venue")
        fetchRequest.predicate  = NSPredicate(format: "name == %@", venueName)
        
        do {
            let results = try context.executeFetchRequest(fetchRequest) as! [Venue]
            
            if results.count > 0 {
                return results[0]
            }
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // create a new record
        return Venue(name: venueName, longitude: 0, latitude: 0, context: context)
    }
    
    func venueList(nameFilter : String) -> [Venue] {
        let fetchRequest        = NSFetchRequest(entityName: "Venue")
        fetchRequest.predicate  = NSPredicate(format: "name CONTAINS[cd] %@", nameFilter)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest) as! [Venue]
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return []
        }
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