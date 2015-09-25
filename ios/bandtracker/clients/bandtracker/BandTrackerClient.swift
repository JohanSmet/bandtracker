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
    
    func bandsFindByName(pattern : String, completionHandler: (bands : [ServerBand]?, error : String?) -> Void) {
        
        let parameters : [String : AnyObject] = [
            "name": pattern
        ]
        
        startTaskGET(BandTrackerClient.BASE_URL, method: "bands/find-by-name", parameters: parameters) { result, error in
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
