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
    
    func searchSetlist(_ gig : Gig, completionHandler : @escaping (_ setList : [SetPart]?, _ setListUrl : String?, _ error : String?) -> Void) {
        
        // configure request
        let parameters : [String : AnyObject] = [
            "artistMbid": gig.band.bandMBID as AnyObject,
            "date" : (DateUtils.format(gig.startDate, format: "dd-MM-yyyy")) as AnyObject
        ]
        
        // perform request
        let _ = startTaskGET(SetlistFmClient.BASE_URL, method: "search/setlists.json", parameters: parameters) { result, error in
            if let basicError = error as? NSError {
                return completionHandler(nil, nil, SetlistFmClient.formatBasicError(basicError))
            } else if let httpError = error as? HTTPURLResponse {
                return completionHandler(nil, nil, SetlistFmClient.formatHttpError(httpError))
            }
            
            // don't exit this scope with calling the completion handler
            var setList : [SetPart] = []
            var setUrl  : String = ""
            defer { completionHandler(setList, setUrl, nil) }
            
            // parse the results
            guard let postResult = result as? NSDictionary else { return }
            guard let fmSetlist = (postResult["setlists"] as? NSDictionary)?["setlist"] as? NSDictionary else { return }
            setUrl = fmSetlist["url"] as? String ?? ""
            
            guard let fmSetsObject = (fmSetlist["sets"] as? NSDictionary)?["set"] else { return }
           
            // fmSetsObject can be an array of objects or just an object
            if let fmSets = fmSetsObject as? [[String : AnyObject]] {
                for fmSet in fmSets {
                    if let set = self.parseSet(fmSet) {
                        setList.append(set)
                    }
                }
            }
            
            if let fmSet = fmSetsObject as? [String : AnyObject] {
                if let set = self.parseSet(fmSet) {
                    setList.append(set)
                }
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
        } else if (response.statusCode == 404) {
            return NSLocalizedString("cliSelListNotFound", comment:"No setlist found for the request date.")
        } else {
            return "HTTP-error \(response.statusCode)"
        }
    }
    
    fileprivate func parseSet(_ fmSet :  [String : AnyObject]) -> SetPart? {
        var set = SetPart()
        
        if let name = fmSet["name"] as? String {
            set.name = name
        } else if let encore = fmSet["@encore"] as? String {
            set.name = "Encore \(encore)"
        }
        
        guard let songs = fmSet["song"] as? [[String : AnyObject]] else { return nil }
        
        for song in songs {
            set.songs.append(song["@name"] as! String)
        }
        
        return set
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
