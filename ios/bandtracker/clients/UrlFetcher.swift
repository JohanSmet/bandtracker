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
    
    static fileprivate var urlSession : URLSession?
    
    
   
    static func loadImageFromUrl(_ urlString : String, completionHandlerUI : @escaping (_ image : UIImage?) -> Void) {
        
        // create session if necessary
        if (urlSession == nil) {
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad;
            
            urlSession = URLSession(configuration: sessionConfiguration)
        }
        
        // configure request
        guard let url  = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        
        // execute request
        let task = urlSession!.dataTask(with: request, completionHandler: { data, response, urlError in
            if let data = data {
                DispatchQueue.main.async {
                    completionHandlerUI(UIImage(data: data))
                }
            }
        }) 
        
        task.resume()
    }
}
