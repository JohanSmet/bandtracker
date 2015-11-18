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
    
    func login(completionHandler: (error : String?) -> Void) {
       
        let postBody : [ String : AnyObject] = [
            "name"   : BandTrackerClient.USERNAME,
            "passwd" : BandTrackerClient.PASSWORD
        ]
        
        startTaskPOST(BandTrackerClient.BASE_URL, method: "auth/login", parameters: [:], jsonBody: postBody) { result, error in
            if let postResult = result as? NSDictionary {
                self.apiToken = postResult.valueForKey("token") as? String
            }
            
            if let basicError = error as? NSError {
                completionHandler(error: BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(error: BandTrackerClient.formatHttpError(httpError))
            } else {
                completionHandler(error: nil);
            }
        }
        
    }
    
    func bandsFindByName(pattern : String, completionHandler: (bands : [BandTrackerClient.Band]?, error : String?, requestTimeStamp : NSTimeInterval) -> Void) {
        
        let timeStamp = NSDate.timeIntervalSinceReferenceDate()
       
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(bands: nil, error: error, requestTimeStamp: timeStamp)
                } else {
                    self.bandsFindByName(pattern, completionHandler: completionHandler);
                }
            }
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
                completionHandler(bands: nil, error: BandTrackerClient.formatBasicError(basicError), requestTimeStamp: timeStamp)
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(bands: nil, error: BandTrackerClient.formatHttpError(httpError), requestTimeStamp: timeStamp)
            } else {
                let postResult = result as! [AnyObject];
                var bands : [BandTrackerClient.Band] = []
                
                for bandDictionary in postResult {
                    bands.append(BandTrackerClient.Band(values: bandDictionary as! [String : AnyObject]))
                }
                
                completionHandler(bands : bands, error : nil, requestTimeStamp: timeStamp)
            }
        }
    }
    
    func cityFind(pattern : String, countryCode : String?, completionHandler : (cities : [String]?, error : String?, requestTimeStamp : NSTimeInterval) -> Void) {
        
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(cities: nil, error: error, requestTimeStamp: 0)
                } else {
                    self.cityFind(pattern, countryCode: countryCode, completionHandler: completionHandler)
                }
            }
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
        
        let timeStamp = NSDate.timeIntervalSinceReferenceDate()
        
        // execute request
        startTaskGET(BandTrackerClient.BASE_URL, method: "city/find", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(cities: nil, error: BandTrackerClient.formatBasicError(basicError), requestTimeStamp: timeStamp)
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(cities: nil, error: BandTrackerClient.formatHttpError(httpError), requestTimeStamp: timeStamp)
            } else {
                let postResult = result as! [String]
                completionHandler(cities : postResult, error : nil, requestTimeStamp: timeStamp)
            }
        }
    }
    
    func venueFind(pattern : String, countryCode : String?, city : String?, completionHandler : (venues : [String]?, error : String?, requestTimeStamp : NSTimeInterval) -> Void)  {
        
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(venues: nil, error: error, requestTimeStamp: 0)
                } else {
                    self.venueFind(pattern, countryCode: countryCode, city: city, completionHandler: completionHandler)
                }
            }
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
        
        let timeStamp = NSDate.timeIntervalSinceReferenceDate()
        
        // execute request
        startTaskGET(BandTrackerClient.BASE_URL, method: "venue/find", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(venues: nil, error: BandTrackerClient.formatBasicError(basicError), requestTimeStamp: timeStamp)
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(venues: nil, error: BandTrackerClient.formatHttpError(httpError), requestTimeStamp: timeStamp)
            } else {
                let postResult = result as! [String]
                completionHandler(venues : postResult, error : nil, requestTimeStamp: timeStamp)
            }
        }
    }
    
    func tourDateFind(bandMBID : String, dateFrom : NSDate?, dateTo : NSDate?, countryCode : String?, location : String?,
                      completionHandler : (tourDates : [BandTrackerClient.TourDate]?, error : String?, requestTimeStamp : NSTimeInterval) -> Void) {
       
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(tourDates: nil, error: error, requestTimeStamp: 0)
                } else {
                    self.tourDateFind(bandMBID, dateFrom: dateFrom, dateTo: dateTo, countryCode: countryCode, location: location, completionHandler: completionHandler)
                }
            }
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
        
        let timeStamp = NSDate.timeIntervalSinceReferenceDate()
        
        // execute request
        startTaskGET(BandTrackerClient.BASE_URL, method: "tourdate/find", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(tourDates: nil, error: BandTrackerClient.formatBasicError(basicError), requestTimeStamp: timeStamp)
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(tourDates: nil, error: BandTrackerClient.formatHttpError(httpError), requestTimeStamp: timeStamp)
            } else {
                let postResult = result as! [AnyObject];
                var tourDates : [TourDate] = []
                
                for dateDictionary in postResult {
                    if let tourDate = TourDate(values: dateDictionary as! [String : AnyObject]) {
                        tourDates.append(tourDate)
                    }
                }
                
                completionHandler(tourDates: tourDates, error : nil, requestTimeStamp: timeStamp)
            }
        }
    }
    
    func tourDateYears(bandMBID : String, completionHandler : (years : [Int]?, error : String?) -> Void) {
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(years: nil, error: error)
                } else {
                    self.tourDateYears(bandMBID, completionHandler: completionHandler)
                }
            }
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
    
    func countrySync(syncId : Int, completionHandler : (syncId : Int, countries : [BandTrackerClient.Country]?, error : String?) -> Void) {
        
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(syncId: 0, countries: nil, error: error)
                } else {
                    self.countrySync(syncId, completionHandler: completionHandler)
                }
            }
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
                var countries :  [BandTrackerClient.Country] = []
                
                for country in postResult.valueForKey("countries") as! [[String : AnyObject]] {
                    countries.append(BandTrackerClient.Country(values: country))
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
