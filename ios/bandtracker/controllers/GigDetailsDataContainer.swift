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
    var embeddedVc   : GigDetailsSubView!
    var editable     : Bool = false
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if segue.identifier == "embedGigDetailsData" {
            embeddedVc = segue.destinationViewController as! GigDetailsSubView
            embeddedVc.gig = gig
            embeddedVc.setEditableControls(editable)
        }
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // GigDetailsSubView
    //
    
    func setEditableControls(edit: Bool) {
        if let vc = embeddedVc {
            vc.setEditableControls(edit)
        }
        editable = edit
    }

}