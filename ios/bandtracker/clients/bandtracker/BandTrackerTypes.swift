//
//  BandTrackerTypes.swift
//  bandtracker
//
//  Created by Johan Smet on 12/11/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

extension BandTrackerClient {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // nested types
    //
    
    class Band {
        
        var MBID        : String
        var name        : String
        var genre       : String
        var imageUrl    : String
        var biography   : String
        var source      : String
        
        init(values : [ String : AnyObject ]) {
            self.MBID       = values["MBID"] as! String
            self.name       = values["name"] as! String
            self.genre      = values["genre"] as! String
            self.imageUrl   = values["imageUrl"] as! String
            self.biography  = values["biography"] as? String ?? ""
            self.source     = values["source"] as? String ?? ""
        }
    }
    
    struct Country {
        var code : String
        var name : String
        var flag : String
        
        init(values : [ String : AnyObject ]) {
            self.code = values["code"] as! String
            self.name = values["name"] as! String
            self.flag = values["flag"] as? String ?? ""
        }
    }
    
    struct TourDate {
        
        var bandId : String
        var startDate : Date
        var endDate : Date
        var stage : String
        var venue : String
        var city : String
        var countryCode : String
        var supportAct : Bool
        
        init? (values : [String : AnyObject]) {
            guard let gigStart = DateUtils.dateFromStringISO(values["startDate"] as? String ?? "") else { return nil }
            guard let gigEnd   = DateUtils.dateFromStringISO(values["endDate"]   as? String ?? "") else { return nil }
            
            
            bandId      = values["bandId"]      as? String ?? ""
            startDate   = gigStart
            endDate     = gigEnd
            stage       = values["stage"]       as? String ?? ""
            venue       = values["venue"]       as? String ?? ""
            city        = values["city"]        as? String ?? ""
            countryCode = values["countryCode"] as? String ?? ""
            supportAct  = values["supportAct"]  as? Bool   ?? false
        }
    }
    
}
