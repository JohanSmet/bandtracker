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
    
    fileprivate var webClient : WebApiClient = WebApiClient(dataOffset: 0)
    
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

    func getBandFanart(_ bandMbid : String, completionHandler : @escaping (_ fanart : BandFanart?, _ error : String?) -> Void) {
        
        // configure request
        let parameters : [String : AnyObject] = [
            "api_key": FanartTvClient.API_KEY as AnyObject
        ]
        
        let _ = webClient.startTaskGET(FanartTvClient.BASE_URL, method: "music/\(bandMbid)", parameters: parameters) { result, error in
            
            if let basicError = error as? NSError {
                return completionHandler(nil, FanartTvClient.formatBasicError(basicError))
            } else if let httpError = error as? HTTPURLResponse {
                return completionHandler(nil, FanartTvClient.formatHttpError(httpError))
            }
            
            // don't exit this scope with calling the completion handler
            var bandFanart = BandFanart(bandThumbnailUrl: "", bandLogoUrl: "")
            defer { completionHandler(bandFanart, nil) }
            
            // parse the response
            guard let postResult = result as? NSDictionary else { return }
            
            if let thumbs = postResult["artistthumb"] as? [AnyObject] {
                bandFanart.bandThumbnailUrl = ((thumbs[0] as! [String : AnyObject])["url"] as! String).replacingOccurrences(of: "/fanart/", with: "/preview/")
            }
            
            if let logos = postResult["hdmusiclogo"] as? [AnyObject] {
                bandFanart.bandLogoUrl = ((logos[0] as! [String : AnyObject])["url"] as! String).replacingOccurrences(of: "/fanart/", with: "/preview/")
            }
            
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    fileprivate class func formatBasicError(_ error : NSError) -> String {
        return error.localizedDescription
    }
    
    fileprivate class func formatHttpError(_ response : HTTPURLResponse) -> String {
        
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
