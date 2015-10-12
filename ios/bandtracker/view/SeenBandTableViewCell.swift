//
//  SeenBandTableViewCell.swift
//  bandtracker
//
//  Created by Johan Smet on 11/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class SeenBandTableViewCell : UITableViewCell {
    
    @IBOutlet weak var bandImage: UIImageView!
    @IBOutlet weak var bandName: UILabel!
    @IBOutlet weak var numberOfGigs: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
}