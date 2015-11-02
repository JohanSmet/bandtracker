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
    
    static var urlSession : NSURLSession?
   
    static func loadImageFromUrl(urlString : String, completionHandlerUI : (image : UIImage?) -> Void) {
        
        // create session if necessary
        if (urlSession == nil) {
            let cache = NSURLCache(memoryCapacity: 64 * 1024 * 1024, diskCapacity: 512 * 1024 * 1024, diskPath: "img-cache")
            
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfiguration.URLCache = cache
            sessionConfiguration.requestCachePolicy = .ReturnCacheDataElseLoad;
            
            urlSession = NSURLSession(configuration: sessionConfiguration)
        }
        
        // configure request
        guard let url  = NSURL(string: urlString) else { return }
        let request = NSURLRequest(URL: url)
        
        // execute request
        let task = urlSession!.dataTaskWithRequest(request) { data, response, urlError in
            if let data = data {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerUI(image: UIImage(data: data))
                }
            }
        }
        
        task.resume()
    }
}