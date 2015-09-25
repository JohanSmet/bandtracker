//
//  EventsSeenController.swift
//  bandtracker
//
//  Created by Johan Smet on 21/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import UIKit

class EventsSeenController: UITableViewController,
                            MainTabSheet {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewController
    //
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // MainTabSheet
    //
    
    func updateSearchResults(searchText : String) {
        
    }
    
    func addNewItem() {
    }
    
    var searchBarVisible : Bool { return true }
    var addButtonVisible : Bool { return true }

}
