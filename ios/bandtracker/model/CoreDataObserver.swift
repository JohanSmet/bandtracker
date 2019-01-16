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
    func coreDataObserver(_ coreDataObserver : CoreDataObserver, didChange object : NSManagedObject)
}

class CoreDataObserver : NSObject {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var delegate : CoreDataObserverDelegate?
    
    fileprivate var context         : NSManagedObjectContext
    fileprivate var observedObjects : [NSManagedObject] = []
    
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
    
    func startObservingObject(_ subject : NSManagedObject) {
        if observedObjects.isEmpty {
            activateObserver()
        }
        
        observedObjects.append(subject)
    }
    
    func stopObservingObject(_ subject : NSManagedObject) {
        
        if let idx = observedObjects.index(of: subject) {
            observedObjects.remove(at: idx)
        }
        
        if observedObjects.isEmpty {
            deactivateObserver()
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    fileprivate func activateObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(CoreDataObserver.dataModelChangeNotification(_:)),
                                                            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                                            object: context)
    }
    
    fileprivate func deactivateObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
    }
    
    @objc func dataModelChangeNotification(_ notification: Notification) {
        guard let delegate = self.delegate else { return }
        
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet {
            for observed in observedObjects {
                if updatedObjects.contains(observed) {
                    delegate.coreDataObserver(self, didChange: observed)
                }
            }
        }
    }
    
}
