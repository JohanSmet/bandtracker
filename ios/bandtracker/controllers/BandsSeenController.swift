//
//  BandsSeenController.swift
//  bandtracker
//
//  Created by Johan Smet on 20/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit


class BandsSeenController:  UITableViewController,
                            MainTabSheet {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // MainTabSheet
    //
    
    func updateSearchResults(searchText : String) {
        
    }
    
    func addNewItem() {
        self.performSegueWithIdentifier("bandSearchSegue", sender: self)
    }
        
    var searchBarVisible : Bool { return true }
    var addButtonVisible : Bool { return true }
}