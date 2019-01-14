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
   
    static func loadCountries(_ completionHandlerUI : @escaping (_ error : String?) -> Void) {
        
        // load information about last synchronization
        let defaults = UserDefaults.standard;
        let syncId = defaults.integer(forKey: "countrySyncId")
        
        if let syncDate = defaults.object(forKey: "countrySyncDate") as? Date {
            // don't try to sync more than once a day
            if Calendar.current.isDateInToday(syncDate) {
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
                        oldCountry.flag = Data(base64Encoded: serverCountry.flag, options: .ignoreUnknownCharacters)
                    } else {
                        let country = Country(code: serverCountry.code, name: serverCountry.name, context: coreDataStackManager().managedObjectContext!)
                        country.flag = Data(base64Encoded: serverCountry.flag, options: .ignoreUnknownCharacters)
                    }
                }
                
                try coreDataStackManager().managedObjectContext!.save()
                
                defaults.set(syncId, forKey: "countrySyncId")
                defaults.set(Date(), forKey: "countrySyncDate")
                
            } catch let error as NSError {
                completionHandlerUI(error.description)
            }
        }
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    fileprivate static func runCompletionHandler(_ error : String?, completionHandlerUI : @escaping (_ error : String?) -> Void) {
        DispatchQueue.main.async {
            completionHandlerUI(error)
        }
    }
}
