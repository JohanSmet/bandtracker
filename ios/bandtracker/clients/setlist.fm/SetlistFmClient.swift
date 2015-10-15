//
//  SetlistFmClient.swift
//  bandtracker
//
//  Created by Johan Smet on 12/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

class SetlistFmClient : WebApiClient {
    
    struct SetPart {
        var name  : String?
        var songs : [String] = []
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // configuration
    //
    
    static let BASE_URL : String = "http://api.setlist.fm/rest/0.1/"
    static let API_KEY : String  = "e8ed1d50-86d5-4112-92a6-59041dfea3ac"
    
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
    
    func searchSetlist(gig : Gig, completionHandler : (setList : [SetPart]?, setListUrl : String?, error : String?) -> Void) {
        
        // configure request
        let parameters : [String : AnyObject] = [
            "artistMbid": gig.band.bandMBID,
            "date" : DateUtils.format(gig.startDate, format: "dd-MM-yyyy")
        ]
        
        // perform request
        startTaskGET(SetlistFmClient.BASE_URL, method: "search/setlists.json", parameters: parameters) { result, error in
            if let basicError = error as? NSError {
                return completionHandler(setList: nil, setListUrl : nil, error: SetlistFmClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                return completionHandler(setList: nil, setListUrl : nil, error: SetlistFmClient.formatHttpError(httpError))
            }
            
            // don't exit this scope with calling the completion handler
            var setList : [SetPart] = []
            var setUrl  : String = ""
            defer { completionHandler(setList : setList, setListUrl : setUrl, error: nil) }
            
            // parse the results
            guard let postResult = result as? NSDictionary else { return }
            guard let fmSetlist = (postResult["setlists"] as? NSDictionary)?["setlist"] as? NSDictionary else { return }
            guard let fmSets = (fmSetlist["sets"] as? NSDictionary)?["set"] as? [[String : AnyObject]] else { return }
            
            setUrl = fmSetlist["url"] as? String ?? ""
           
            for fmSet in fmSets {
                var set = SetPart()
                
                if let name = fmSet["name"] as? String {
                    set.name = name
                } else if let encore = fmSet["@encore"] as? String {
                    set.name = "Encore \(encore)"
                }
                
                guard let songs = fmSet["song"] as? [[String : AnyObject]] else { break }
                for song in songs {
                    set.songs.append(song["@name"] as! String)
                }
                
                setList.append(set)
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
    
    static let instance = SetlistFmClient()
}

func setlistFmClient() -> SetlistFmClient {
    return SetlistFmClient.instance
}