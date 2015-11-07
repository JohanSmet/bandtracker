//
//  ServerCountry.swift
//  bandtracker
//
//  Created by Johan Smet on 06/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

struct ServerCountry {
    var code : String
    var name : String
    var flag : String
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // properties
    //
    
    init(values : [ String : AnyObject ]) {
        self.code = values["code"] as! String
        self.name = values["name"] as! String
        self.flag = values["flag"] as? String ?? ""
    }
}