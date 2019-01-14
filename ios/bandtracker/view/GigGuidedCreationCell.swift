//
//  GigGuidedCreationCell.swift
//  bandtracker
//
//  Created by Johan Smet on 31/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class GigGuidedCreationCell : UITableViewCell {
   
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setLocation(_ tourDate : BandTrackerClient.TourDate) {
        var location  : String = ""
        var separator : String = ""
        
        if !tourDate.venue.isEmpty {
            location += separator + tourDate.venue
            separator = ", "
        }
        
        if !tourDate.city.isEmpty {
            location += separator + tourDate.city
            separator = ", "
        }
        
        location += separator + tourDate.countryCode
        locationLabel.text = location
    }
    
}
