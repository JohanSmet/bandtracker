//
//  SeenGigTableViewCell.swift
//  bandtracker
//
//  Created by Johan Smet on 21/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class SeenGigTableViewCell : UITableViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    
    func setLocation(gig : Gig) {
        var location  : String = ""
        var separator : String = ""
        
        if let venue = gig.venue {
            location += separator + venue.name
            separator = ", "
        }
        
        if let city = gig.city {
            location += separator + city.name
            separator = ", "
        }
        
        location += separator + gig.country.name
        locationLabel.text = location
    }
    
}