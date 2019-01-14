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
        let modelURL = Bundle.main.url(forResource: MODEL_NAME, withExtension: "momd")!
        let model    = NSManagedObjectModel(contentsOf: modelURL)!
        
        // create the coordinator with the model
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // build the path to the database file
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let storeUrl = urls.first!.appendingPathComponent(SQLITE_FILE_NAME)
        
        
        do {
            
            // deploy pre-populated database on first run
            if !(storeUrl as NSURL).checkResourceIsReachableAndReturnError(nil) {
                if let bundleUrl = Bundle.main.url(forResource: MODEL_NAME, withExtension: "sqlite") {
                    try fileManager.copyItem(at: bundleUrl, to: storeUrl)
                }
            }
            
            // create the persistent store
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
            
            // finally, create the managed object context
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            
            return managedObjectContext
            
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            return nil                                    // exit !!!
        }
        
    }()
    
    func childObjectContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = managedObjectContext
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
    
    func saveChildContext(_ childContext : NSManagedObjectContext) -> Bool {
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
