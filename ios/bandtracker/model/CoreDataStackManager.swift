//
//  CoreDataStackManager.swift
//  BandTracker
//
//  Created by Johan Smet on 09/25/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

private let SQLITE_FILE_NAME = "BandTracker.sqlite"
private let MODEL_NAME       = "BandTracker"

class CoreDataStackManager {
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        // create the managed object model
        let modelURL = NSBundle.mainBundle().URLForResource(MODEL_NAME, withExtension: "momd")!
        let model    = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        // create the coordinator with the model
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // build the path to the database file
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let storeUrl = urls.first!.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        
        do {
            
            // deploy pre-populated database on first run
            if !storeUrl.checkResourceIsReachableAndReturnError(nil) {
                if let bundleUrl = NSBundle.mainBundle().URLForResource(MODEL_NAME, withExtension: "sqlite") {
                    try fileManager.copyItemAtURL(bundleUrl, toURL: storeUrl)
                }
            }
            
            // create the persistent store
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: nil)
            
            // finally, create the managed object context
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            
            return managedObjectContext
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return nil                                    // exit !!!
        }
        
    }()
    
    func childObjectContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = managedObjectContext
        return context
    }
    
    func saveContext () -> Bool {
        
        if managedObjectContext == nil {
            return false
        }
        
        if !managedObjectContext!.hasChanges {
            return true
        }
        
        do {
            try managedObjectContext!.save()
            return true
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return false
        }
    }
    
    func saveChildContext(childContext : NSManagedObjectContext) -> Bool {
        do {
            try childContext.save()
            return true
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return false
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //
    
    static let sharedInstance = CoreDataStackManager()
}

// shorthand way to get the CoreDataStackManager shared instance
func coreDataStackManager() -> CoreDataStackManager {
    return CoreDataStackManager.sharedInstance
}
