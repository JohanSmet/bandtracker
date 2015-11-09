//
//  TimelineTableViewCell.swift
//  bandtracker
//
//  Created by Johan Smet on 31/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class TimelineTableViewCell : UITableViewCell {
    
    @IBOutlet weak var bandLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var countryImage: UIImageView!
    
    
    func setFields(gig : Gig) {
    
        bandLabel.text      = gig.band.name
        dateLabel.text      = DateUtils.toDateStringMedium(gig.startDate)
        ratingControl.rating = gig.rating.floatValue / 10
        if let flag = gig.country.flag {
            countryImage.image   = UIImage(data: flag)
        }
        
        setLocation(gig)
        
    }
    
    private func setLocation(gig : Gig) {
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