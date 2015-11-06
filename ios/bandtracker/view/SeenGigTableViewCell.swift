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
    @IBOutlet weak var countryImage: UIImageView!
    
    func setFields(gig : Gig) {
        
        dateLabel.text = DateUtils.toDateStringMedium(gig.startDate)
        ratingControl.rating = gig.rating.floatValue / 10
        countryImage.image = UIImage(data: gig.country.flag)
        
        setLocation(gig)
        
    }
    
    func setLocation(gig : Gig) {
        var location  : String = ""
        var separator : String = ""
        var venueSet  : Bool   = false
        
        if let venue = gig.venue {
            location += separator + venue.name
            separator = ", "
            venueSet  = true
        }
        
        if let city = gig.city {
            location += separator + city.name
            separator = ", "
        }
        
        if !venueSet {
            location += separator + gig.country.name
        }
        
        locationLabel.text = location
    }
    
}