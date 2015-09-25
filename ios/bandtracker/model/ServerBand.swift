//
//  ServerBand.swift
//  bandtracker
//
//  Created by Johan Smet on 23/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

class ServerBand {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // properties
    //
    
    var MBID        : String
    var name        : String
    var genre       : String
    var imageUrl    : String
    var biography   : String
    var source      : String
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // properties
    //
    
    init(values : [ String : AnyObject ]) {
        self.MBID       = values["MBID"] as! String
        self.name       = values["name"] as! String
        self.genre      = values["genre"] as! String
        self.imageUrl   = values["imageUrl"] as! String
        self.biography  = values["biography"] as? String ?? ""
        self.source     = values["source"] as? String ?? ""
    }
}
