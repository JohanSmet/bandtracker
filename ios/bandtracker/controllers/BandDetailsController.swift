//
//  BandDetailsController.swift
//  bandtracker
//
//  Created by Johan Smet on 26/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class BandDetailsController : UIViewController {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var band : Band!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet var pageTitle: UINavigationItem!
    @IBOutlet var bandImage: UIImageView!
    @IBOutlet var biography: UITextView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        pageTitle.title = band.name
        biography.text  = band.biography
        loadBandImageAsync()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func addGig(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        let newVC = storyboard.instantiateViewControllerWithIdentifier("GigDetailsController")
        navigationController?.pushViewController(newVC, animated: true)
    }
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func loadBandImageAsync() {
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            guard let url  = NSURL(string: self.band.imageUrl) else { return }
            let data = NSData(contentsOfURL: url)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.bandImage.image = UIImage(data: data!)
            }
        }
    }
}