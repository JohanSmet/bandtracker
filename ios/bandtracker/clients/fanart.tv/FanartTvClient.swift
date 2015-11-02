//
//  FanartTvClient.swift
//  bandtracker
//
//  Created by Johan Smet on 01/11/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

class FanartTvClient {
    
    struct BandFanart {
        var bandThumbnailUrl : String
        var bandLogoUrl : String
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private var webClient : WebApiClient = WebApiClient(dataOffset: 0)
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // configuration
    //
    
    static let BASE_URL : String = "http://webservice.fanart.tv/v3/"
    static let API_KEY : String  = "ac9abc733f22a965f1a9579d648c1c9b"


    ///////////////////////////////////////////////////////////////////////////////////
    //
    // request interface
    //

    func getBandFanart(bandMbid : String, completionHandler : (fanart : BandFanart?, error : String?) -> Void) {
        
        // configure request
        let parameters : [String : AnyObject] = [
            "api_key": FanartTvClient.API_KEY
        ]
        
        webClient.startTaskGET(FanartTvClient.BASE_URL, method: "music/\(bandMbid)", parameters: parameters) { result, error in
            
            if let basicError = error as? NSError {
                return completionHandler(fanart: nil, error: FanartTvClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                return completionHandler(fanart: nil, error: FanartTvClient.formatHttpError(httpError))
            }
            
            // don't exit this scope with calling the completion handler
            var bandFanart = BandFanart(bandThumbnailUrl: "", bandLogoUrl: "")
            defer { completionHandler(fanart : bandFanart, error: nil) }
            
            // parse the response
            guard let postResult = result as? NSDictionary else { return }
            
            if let thumbs = postResult["artistthumb"] as? [AnyObject] {
                bandFanart.bandThumbnailUrl = ((thumbs[0] as! [String : AnyObject])["url"] as! String).stringByReplacingOccurrencesOfString("/fanart/", withString: "/preview/")
            }
            
            if let logos = postResult["hdmusiclogo"] as? [AnyObject] {
                bandFanart.bandLogoUrl = ((logos[0] as! [String : AnyObject])["url"] as! String).stringByReplacingOccurrencesOfString("/fanart/", withString: "/preview/")
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
    
    static let instance = FanartTvClient()
}

func fanartTvClient() -> FanartTvClient {
    return FanartTvClient.instance
}