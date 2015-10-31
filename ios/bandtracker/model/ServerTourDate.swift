//
//  ServerTourDate.swift
//  bandtracker
//
//  Created by Johan Smet on 28/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

struct ServerTourDate {
    var code : String
    var name : String
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // properties
    //
    
    init(values : [ String : AnyObject ]) {
        self.code = values["code"] as! String
        self.name = values["name"] as! String
    }
}