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
        
        guard let url  = NSURL(string: urlString) else { return }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url)) { data, response, urlError in
            if let data = data {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerUI(image: UIImage(data: data))
                }
            }
        }
        
        task.resume()
    }
}