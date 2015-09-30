//
//  BandTrackerClient.swift
//  bandtracker
//
//  Created by Johan Smet on 23/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

class BandTrackerClient : WebApiClient {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // configuration
    //
    
    static let BASE_URL : String = "https://bandtracker-justcode.rhcloud.com/api/"
    
    static let USERNAME : String = "ios-development"
    static let PASSWORD : String = "test"
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var apiToken : String!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initializers
    //
    
    override init() {
        super.init(dataOffset: 0)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // request interface
    //
    
    func login(completionHandler: () -> Void) {
       
        let postBody : [ String : AnyObject] = [
            "name"   : BandTrackerClient.USERNAME,
            "passwd" : BandTrackerClient.PASSWORD
        ]
        
        startTaskPOST(BandTrackerClient.BASE_URL, method: "auth/login", parameters: [:], jsonBody: postBody) { result, error in
            if let postResult = result as? NSDictionary {
                self.apiToken = postResult.valueForKey("token") as? String
                if let _ = self.apiToken {
                    completionHandler();
                }
            }
        }
        
    }
    
    func bandsFindByName(pattern : String, completionHandler: (bands : [ServerBand]?, error : String?) -> Void) {
       
        // make sure to login first
        guard let token = apiToken else {
            return login() { self.bandsFindByName(pattern, completionHandler: completionHandler); }
        }
        
        // configure request
        let parameters : [String : AnyObject] = [
            "name": pattern
        ]
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        // execute request
        startTaskGET(BandTrackerClient.BASE_URL, method: "bands/find-by-name", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(bands: nil, error: BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(bands: nil, error: BandTrackerClient.formatHttpError(httpError))
            } else {
                let postResult = result as! [AnyObject];
                var bands : [ServerBand] = []
                
                for bandDictionary in postResult {
                    bands.append(ServerBand(values: bandDictionary as! [String : AnyObject]))
                }
                
                completionHandler(bands : bands, error : nil)
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private class func formatBasicError(error : NSError) -> String {
        return error.localizedDescription
    }
    
    private class func formatHttpError(response : NSHTTPURLResponse) -> String {
        
        if (response.statusCode == 403) {
            return NSLocalizedString("cliInvalidCredentials", comment:"Invalid username or password")
        } else {
            return "HTTP-error \(response.statusCode)"
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //
    
    static let instance = BandTrackerClient()
}

func bandTrackerClient() -> BandTrackerClient {
    return BandTrackerClient.instance
}
