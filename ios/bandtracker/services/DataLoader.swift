//
//  DataLoader.swift
//  bandtracker
//
//  Created by Johan Smet on 06/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

class DataLoader {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // request interface
    //
   
    static func loadCountries(completionHandlerUI : (error : String?) -> Void) {
        
        // load information about last synchronization
        let defaults = NSUserDefaults.standardUserDefaults();
        let syncId = defaults.integerForKey("countrySyncId")
        
        if let syncDate = defaults.objectForKey("countrySyncDate") as? NSDate {
            // don't try to sync more than once a day
            if NSCalendar.currentCalendar().isDateInToday(syncDate) {
                return
            }
        }
        
        bandTrackerClient().countrySync(syncId) { syncId, serverCountries, error in
            
            if let error = error {
                return runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
            }
           
            do {
                let countries = dataContext().countryDictionary()
                
                for serverCountry in serverCountries! {
                    if let oldCountry = countries[serverCountry.code] {
                        oldCountry.name = serverCountry.name
                    } else {
                        _ = Country(code: serverCountry.code, name: serverCountry.name, context: coreDataStackManager().managedObjectContext!)
                    }
                }
                
                try coreDataStackManager().managedObjectContext!.save()
                
                defaults.setInteger(syncId, forKey: "countrySyncId")
                defaults.setObject(NSDate(), forKey: "countrySyncDate")
                
            } catch let error as NSError {
                completionHandlerUI(error: error.description)
            }
        }
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    private static func runCompletionHandler(error : String?, completionHandlerUI : (error : String?) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            completionHandlerUI(error: error)
        }
    }
}
