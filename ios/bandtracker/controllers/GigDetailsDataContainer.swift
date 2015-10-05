//
//  GigDetailsDataContainer.swift
//  bandtracker
//
//  Created by Johan Smet on 04/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class GigDetailsDataContainer : UIViewController,
                                GigDetailsSubView {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var gig : Gig!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if segue.identifier == "embedGigDetailsData" {
            var embeddedVc = segue.destinationViewController as! GigDetailsSubView
            embeddedVc.gig = gig
        }
        
    }

}