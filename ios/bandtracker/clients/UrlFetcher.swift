//
//  UrlFetcher.swift
//  bandtracker
//
//  Created by Johan Smet on 11/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class UrlFetcher {
   
    static func loadImageFromUrl(urlString : String, completionHandlerUI : (image : UIImage?) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            guard let url  = NSURL(string: urlString) else { return }
            let data = NSData(contentsOfURL: url)
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandlerUI(image: UIImage(data: data!))
            }
        }
    }
    
    
    
}