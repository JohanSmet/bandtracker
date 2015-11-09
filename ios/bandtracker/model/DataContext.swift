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
        
        // fetch extra data
        fanartTvClient().getBandFanart(band.bandMBID) { fanart, error in
            if let fanart = fanart {
                band.fanartThumbUrl = fanart.bandThumbnailUrl
                band.fanartLogoUrl  = fanart.bandLogoUrl
                coreDataStackManager().saveContext()
            }
        }
        
        return band
    }
    
    func deleteBand(band : Band) {
        coreDataStackManager().managedObjectContext?.deleteObject(band)
        coreDataStackManager().saveContext()
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
    
    func deleteGig(gig : Gig) {
        coreDataStackManager().managedObjectContext?.deleteObject(gig)
        coreDataStackManager().saveContext()
    }
    
    func gigFromTourDate(band : Band, tourDate : BandTrackerClient.TourDate, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> Gig {
        
        let gig = Gig(band: band, context: context)
        gig.startDate   = tourDate.startDate
        gig.endDate     = tourDate.endDate
        gig.stage       = tourDate.stage
        gig.supportAct  = tourDate.supportAct
        gig.country     = countryByCode(tourDate.countryCode, context: gig.managedObjectContext!)
        gig.city        = cityByName(tourDate.city, context: gig.managedObjectContext!)
        gig.venue       = venueByName(tourDate.venue, context: gig.managedObjectContext!)
        
        return gig
    }
    
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
    
    func gigsTop5Countries() -> [Country] {
     
        let countExpDesc = NSExpressionDescription()
        countExpDesc.name = "count"
        countExpDesc.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "startDate")])
        countExpDesc.expressionResultType = .Integer32AttributeType
        
        let fetchRequest = NSFetchRequest(entityName: "Gig")
        fetchRequest.resultType         = .DictionaryResultType
        fetchRequest.propertiesToFetch  = ["country", countExpDesc]
        fetchRequest.propertiesToGroupBy = ["country"]
        
        var topCountries : [Country] = []
        
        do {
            if let results = try coreDataStackManager().managedObjectContext?.executeFetchRequest(fetchRequest) {
                let ordered = results.sort({$0["count"] as! Int > $1["count"] as! Int})
                
                for result in ordered {
                    let objectId = (result as! NSDictionary)["country"] as! NSManagedObjectID
                    topCountries.append(coreDataStackManager().managedObjectContext?.objectWithID(objectId) as! Country)
                }
            }
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        return topCountries
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
    
    func countryByCode(countryCode : String, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> Country {
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest(entityName: "Country")
        fetchRequest.predicate  = NSPredicate(format: "code == %@", countryCode)
        
        do {
            let results = try context.executeFetchRequest(fetchRequest) as! [Country]
            
            if results.count > 0 {
                return results[0]
            }
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // create a new record (XXX this makes no sense ...)
        let country = Country(code: countryCode, name: countryCode, context: context)
        return country
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