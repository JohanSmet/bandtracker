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
    // database management
    //
    
    func deleteAllData() {
        
        do {
            try deleteResults(NSFetchRequest(entityName: "Gig"))
            try deleteResults(NSFetchRequest(entityName: "Band"))
            try deleteResults(NSFetchRequest(entityName: "Venue"))
            try deleteResults(NSFetchRequest(entityName: "City"))
            self.saveContext()
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func deleteResults(_ fetchRequest : NSFetchRequest<NSFetchRequestResult>) throws {
        guard let context = coreDataStackManager().managedObjectContext else { return }
        
        for obj in try context.fetch(fetchRequest) {
            context.delete(obj as! NSManagedObject)
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // band management
    //
    
    func createBand(_ bandTemplate : BandTrackerClient.Band) -> Band {
        // create band
        let band = Band(bandTemplate: bandTemplate, context: coreDataStackManager().managedObjectContext!)
        
        // save all changes
        self.saveContext()
        
        // fetch extra data
        fanartTvClient().getBandFanart(band.bandMBID) { fanart, error in
            if let fanart = fanart {
                band.fanartThumbUrl = fanart.bandThumbnailUrl
                band.fanartLogoUrl  = fanart.bandLogoUrl
                self.saveContext()
            } else {
                band.fanartThumbUrl = band.imageUrl;
                self.saveContext()
            }
        }
        
        return band
    }
    
    func deleteBand(_ band : Band) {
        coreDataStackManager().managedObjectContext?.delete(band)
        saveContext()
    }
    
    func bandList(_ nameFilter : String) -> [Band] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Band")
        if !nameFilter.isEmpty {
            fetchRequest.predicate       = NSPredicate(format: "name CONTAINS[cd] %@", nameFilter)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try coreDataStackManager().managedObjectContext!.fetch(fetchRequest) as! [Band]
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return []
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // gig management
    //
    
    func deleteGig(_ gig : Gig) {
        coreDataStackManager().managedObjectContext?.delete(gig)
        self.saveContext()
    }
    
    func gigFromTourDate(_ band : Band, tourDate : BandTrackerClient.TourDate, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> Gig {
        
        let gig = Gig(band: band, context: context)
        gig.startDate   = DateUtils.stripTime(tourDate.startDate)
        gig.endDate     = DateUtils.stripTime(tourDate.endDate)
        gig.stage       = tourDate.stage
        gig.supportAct  = tourDate.supportAct
        gig.country     = countryByCode(tourDate.countryCode, context: gig.managedObjectContext!)
        gig.city        = cityByName(tourDate.city, context: gig.managedObjectContext!)
        gig.venue       = venueByName(tourDate.venue, context: gig.managedObjectContext!)
        
        return gig
    }
    
    func gigTourDatePresent(_ band : Band, tourDate : BandTrackerClient.TourDate) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gig")
        fetchRequest.predicate      = NSPredicate(format: "band.bandMBID == %@ && startDate == %@ && country.code == %@ && city.name == %@",
                                                    band.bandMBID, DateUtils.stripTime(tourDate.startDate) as CVarArg, tourDate.countryCode, tourDate.city);
        
        do {
            if let results = try coreDataStackManager().managedObjectContext?.fetch(fetchRequest) {
                if !results.isEmpty {
                    return true
                }
            }
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        return false
    }
    
    func totalRatingOfGigs(_ band : Band) -> Int {
        
        let sumExpDesc = NSExpressionDescription()
        sumExpDesc.name = "sumRating"
        sumExpDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "rating")])
        sumExpDesc.expressionResultType = .integer32AttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gig")
        fetchRequest.predicate      = NSPredicate(format: "band.bandMBID == %@", band.bandMBID)
        fetchRequest.resultType     = .dictionaryResultType
        fetchRequest.propertiesToFetch = [sumExpDesc]
        
        do {
            if let results = try coreDataStackManager().managedObjectContext?.fetch(fetchRequest) {
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
        countExpDesc.expressionResultType = .integer32AttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gig")
        fetchRequest.resultType         = .dictionaryResultType
        fetchRequest.propertiesToFetch  = ["country", countExpDesc]
        fetchRequest.propertiesToGroupBy = ["country"]
        
        let sort = NSSortDescriptor	(key: "country", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        var topCountries : [Country] = []
        
        do {
            if let results = try coreDataStackManager().managedObjectContext?.fetch(fetchRequest) {
                for result in results {
                    let objectId = (result as! NSDictionary)["country"] as! NSManagedObjectID
                    topCountries.append(coreDataStackManager().managedObjectContext?.object(with: objectId) as! Country)
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        var results : [String : Country] = [:]
        
        do {
            for country in try coreDataStackManager().managedObjectContext!.fetch(fetchRequest) as! [Country] {
                results[country.code] = country
            }
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
            
        return results
    }
    
    func countryByCode(_ countryCode : String, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> Country {
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        fetchRequest.predicate  = NSPredicate(format: "code == %@", countryCode)
        
        do {
            let results = try context.fetch(fetchRequest) as! [Country]
            
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
    
    func countryByName(_ countryName : String, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> Country {
        
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        fetchRequest.predicate  = NSPredicate(format: "name == %@", countryName)
        
        do {
            let results = try context.fetch(fetchRequest) as! [Country]
           
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
    
    func countryList(_ nameFilter : String) -> [Country] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        fetchRequest.predicate       = NSPredicate(format: "name CONTAINS[cd] %@", nameFilter)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try coreDataStackManager().managedObjectContext!.fetch(fetchRequest) as! [Country]
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return []
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // city
    //
    
    func cityByName(_ cityName : String, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> City? {
        
        if cityName.isEmpty {
            return nil
        }
        
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
        fetchRequest.predicate  = NSPredicate(format: "name == %@", cityName)
        
        do {
            let results = try context.fetch(fetchRequest) as! [City]
            
            if results.count > 0 {
                return results[0]
            }
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // create a new record
        return City(name: cityName, longitude: 0, latitude: 0, context: context)
    }
    
    func cityList(_ nameFilter : String) -> [City] {
        let fetchRequest        = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
        fetchRequest.predicate  = NSPredicate(format: "name CONTAINS[cd] %@", nameFilter)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try coreDataStackManager().managedObjectContext!.fetch(fetchRequest) as! [City]
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return []
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // venue
    //
    
    func venueByName(_ venueName : String, context : NSManagedObjectContext = coreDataStackManager().managedObjectContext!) -> Venue? {
        
        if venueName.isEmpty {
            return nil
        }
        
        // try to fetch an existing record
        let fetchRequest        = NSFetchRequest<NSFetchRequestResult>(entityName: "Venue")
        fetchRequest.predicate  = NSPredicate(format: "name == %@", venueName)
        
        do {
            let results = try context.fetch(fetchRequest) as! [Venue]
            
            if results.count > 0 {
                return results[0]
            }
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        // create a new record
        return Venue(name: venueName, longitude: 0, latitude: 0, context: context)
    }
    
    func venueList(_ nameFilter : String) -> [Venue] {
        let fetchRequest        = NSFetchRequest<NSFetchRequestResult>(entityName: "Venue")
        fetchRequest.predicate  = NSPredicate(format: "name CONTAINS[cd] %@", nameFilter)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try coreDataStackManager().managedObjectContext!.fetch(fetchRequest) as! [Venue]
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return []
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //

    
    private func saveContext() {
        if !coreDataStackManager().saveContext() {
            NSLog("Error saving context")
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
