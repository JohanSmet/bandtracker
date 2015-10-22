//
//  YoutubeDataClient.swift
//  bandtracker
//
//  Created by Johan Smet on 14/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation

class YoutubeDataClient {
    
    struct Video {
        var id          : String = ""
        var title       : String = ""
        var thumbUrl    : String = ""
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
    
    static let BASE_URL : String = "https://www.googleapis.com/youtube/v3/"
    static let API_KEY : String  = "AIzaSyDPoRz5z-Xdrc4sP8N_gCOwdtTkGgZtBFg"
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // request interface
    //
    
    func searchVideosForGig(gig : Gig, song : String?, maxResults : Int, completionHandler : (videos : [Video]?, error : String?) -> Void) {
        
        var parameters : [String : AnyObject] = [
            "key" :     YoutubeDataClient.API_KEY,
            "videoEmbeddable" : "true",
            "type" :            "video",
            "order" :           "relevance",
            "part" :            "snippet",
            "fields" :          "items(id,snippet)",
            "maxResults" :      maxResults
        ]
        
        // build the search query
        let queryDate = DateUtils.format(gig.startDate, format: "yyyy MMM dd")
        var query = "\(gig.band.name) \(queryDate)"
        
        if let city = gig.city {
            query += " " + city.name
        }
        
        if let venue = gig.venue {
            query += " " + venue.name
        }
        
        if let song = song {
            query += " " + song
        }
        
        parameters["q"] = query
        
        // perform the query
        webClient.startTaskGET(YoutubeDataClient.BASE_URL, method: "search", parameters: parameters) { result, error in
            if let basicError = error as? NSError {
                return completionHandler(videos: nil, error: YoutubeDataClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                return completionHandler(videos: nil, error: YoutubeDataClient.formatHttpError(httpError))
            }
            
            // don't exit this scope with calling the completion handler
            var videos : [Video] = []
            defer { completionHandler(videos : videos, error: nil) }
            
            // parse the results
            guard let postResult = result as? NSDictionary else { return }
            guard let items      = postResult["items"] as? [AnyObject] else { return }
            
            for item in items {
                guard let snippet = item["snippet"] as? [String : AnyObject] else { break }
                guard let thumbs  = snippet["thumbnails"] as? [ String : AnyObject ] else { break }
                
                var video = Video()
                video.id        = (item["id"] as? NSDictionary)?["videoId"] as? String ?? ""
                video.title     = snippet["title"] as? String ?? ""
                video.thumbUrl  = (thumbs["medium"] as? NSDictionary)?["url"] as? String ?? ""
                
                videos.append(video)
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
    
    static let instance = YoutubeDataClient()
}

func youtubeDataClient() -> YoutubeDataClient {
    return YoutubeDataClient.instance
}
