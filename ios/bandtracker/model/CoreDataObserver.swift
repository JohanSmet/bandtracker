//
//  CoreDataObserver.swift
//  bandtracker
//
//  Created by Johan Smet on 11/11/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataObserverDelegate {
    func coreDataObserver(coreDataObserver : CoreDataObserver, didChange object : NSManagedObject)
}

class CoreDataObserver : NSObject {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var delegate : CoreDataObserverDelegate?
    
    private var context         : NSManagedObjectContext
    private var observedObjects : [NSManagedObject] = []
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    init(context : NSManagedObjectContext) {
        self.context = context
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // interface
    //
    
    func startObservingObject(subject : NSManagedObject) {
        if observedObjects.isEmpty {
            activateObserver()
        }
        
        observedObjects.append(subject)
    }
    
    func stopObservingObject(subject : NSManagedObject) {
        
        if let idx = observedObjects.indexOf(subject) {
            observedObjects.removeAtIndex(idx)
        }
        
        if observedObjects.isEmpty {
            deactivateObserver()
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func activateObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataModelChangeNotification:",
                                                            name: NSManagedObjectContextObjectsDidChangeNotification,
                                                            object: context)
    }
    
    private func deactivateObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextObjectsDidChangeNotification, object: context)
    }
    
    func dataModelChangeNotification(notification: NSNotification) {
        guard let delegate = self.delegate else { return }
        
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet {
            for observed in observedObjects {
                if updatedObjects.containsObject(observed) {
                    delegate.coreDataObserver(self, didChange: observed)
                }
            }
        }
    }
    
}