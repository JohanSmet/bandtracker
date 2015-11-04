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
    // nested types
    //
    
    class TourDate {
        
        var bandId : String
        var startDate : NSDate
        var endDate : NSDate
        var stage : String
        var venue : String
        var city : String
        var countryCode : String
        var supportAct : Bool
    
        init (values : [String : AnyObject]) {
            bandId      = values["bandId"]      as? String ?? ""
            startDate   = DateUtils.dateFromStringISO(values["startDate"] as? String ?? "")
            endDate     = DateUtils.dateFromStringISO(values["endDate"] as? String ?? "")
            stage       = values["stage"]       as? String ?? ""
            venue       = values["venue"]       as? String ?? ""
            city        = values["city"]        as? String ?? ""
            countryCode = values["countryCode"] as? String ?? ""
            supportAct  = values["supportAct"]  as? Bool   ?? false
        }
    }
    
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
    
    func cityFind(pattern : String, countryCode : String?, completionHandler : (cities : [String]?, error : String?) -> Void) {
        
        // make sure to login first
        guard let token = apiToken else {
            return login() { self.cityFind(pattern, countryCode: countryCode, completionHandler: completionHandler) }
        }
        
        // configure request
        var parameters : [String : AnyObject] = [
            "pattern": pattern
        ]
        
        if let countryCode = countryCode {
            if !countryCode.isEmpty {
                parameters["country"] = countryCode
            }
        }
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        // execute request
        startTaskGET(BandTrackerClient.BASE_URL, method: "city/find", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(cities: nil, error: BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(cities: nil, error: BandTrackerClient.formatHttpError(httpError))
            } else {
                let postResult = result as! [String]
                completionHandler(cities : postResult, error : nil)
            }
        }
    }
    
    func venueFind(pattern : String, countryCode : String?, city : String?, completionHandler : (venues : [String]?, error : String?) -> Void)  {
        
        // make sure to login first
        guard let token = apiToken else {
            return login() { self.venueFind(pattern, countryCode: countryCode, city: city, completionHandler: completionHandler) }
        }
        
        // configure request
        var parameters : [String : AnyObject] = [
            "pattern": pattern
        ]
        
        if let countryCode = countryCode {
            if !countryCode.isEmpty {
                parameters["country"] = countryCode
            }
        }
        
        if let city = city {
            if !city.isEmpty {
                parameters["city"] = city
            }
        }
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        // execute request
        startTaskGET(BandTrackerClient.BASE_URL, method: "venue/find", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(venues: nil, error: BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(venues: nil, error: BandTrackerClient.formatHttpError(httpError))
            } else {
                let postResult = result as! [String]
                completionHandler(venues : postResult, error : nil)
            }
        }
    }
    
    func tourDateFind(bandMBID : String, dateFrom : NSDate?, dateTo : NSDate?, countryCode : String?, location : String?, completionHandler : (tourDates : [BandTrackerClient.TourDate]?, error : String?) -> Void) {
       
        // make sure to login first
        guard let token = apiToken else {
            return login() { self.tourDateFind(bandMBID, dateFrom: dateFrom, dateTo: dateTo, countryCode: countryCode, location: location, completionHandler: completionHandler) }
        }
                        
        // configure request
        var parameters : [String : AnyObject] = [
            "band" : bandMBID
        ]
                        
        if let dateFrom = dateFrom {
            parameters["start"] = DateUtils.format(dateFrom, format: "yyyy-MM-dd")
        }
        
        if let dateTo = dateTo {
            parameters["end"] = DateUtils.format(dateTo, format: "yyyy-MM-dd")
        }
        
        if let countryCode = countryCode {
            parameters["country"] = countryCode
        }
        
        if let location = location {
            parameters["location"] = location
        }
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        // execute request
        startTaskGET(BandTrackerClient.BASE_URL, method: "tourdate/find", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(tourDates: nil, error: BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(tourDates: nil, error: BandTrackerClient.formatHttpError(httpError))
            } else {
                let postResult = result as! [AnyObject];
                var tourDates : [TourDate] = []
                
                for dateDictionary in postResult {
                    tourDates.append(TourDate(values: dateDictionary as! [String : AnyObject]))
                }
                
                completionHandler(tourDates: tourDates, error : nil)
            }
        }
    }
    
    func tourDateYears(bandMBID : String, completionHandler : (years : [Int]?, error : String?) -> Void) {
        // make sure to login first
        guard let token = apiToken else {
            return login() { self.tourDateYears(bandMBID, completionHandler: completionHandler) }
        }
        
        // configure request
        let parameters : [String : AnyObject] = [
            "band": bandMBID
        ]
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        // execute request
        startTaskGET(BandTrackerClient.BASE_URL, method: "tourdate/band-years", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(years: nil, error: BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(years: nil, error: BandTrackerClient.formatHttpError(httpError))
            } else {
                let postResult = result as! [Int]
                completionHandler(years: postResult, error: nil)
            }
        }
        
    }
    
    func countrySync(syncId : Int, completionHandler : (syncId : Int, countries : [ServerCountry]?, error : String?) -> Void) {
        
        // make sure to login first
        guard let token = apiToken else {
            return login() { self.countrySync(syncId, completionHandler: completionHandler) }
        }
        
        // configure request
        let parameters : [String : AnyObject] = [
            "syncId": syncId
        ]
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        // execute request
        startTaskGET(BandTrackerClient.BASE_URL, method: "country/sync", parameters : parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(syncId: 0, countries : nil, error: BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(syncId: 0, countries : nil, error: BandTrackerClient.formatHttpError(httpError))
            } else {
                let postResult = result as! NSDictionary
                var countries :  [ServerCountry] = []
                
                for country in postResult.valueForKey("countries") as! [[String : AnyObject]] {
                    countries.append(ServerCountry(values: country))
                }
                
                completionHandler(syncId: postResult["sync"] as! Int, countries: countries, error: nil);
                    
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
