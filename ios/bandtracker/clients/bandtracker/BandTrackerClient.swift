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
    
    static let BASE_URL : String = "http://ct-nodejs/api/"
    
    static let USERNAME : String = "ios-development"
    static let PASSWORD : String = "test"
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    fileprivate var apiToken : String!
    
    fileprivate let lockQueue = DispatchQueue(label: "be.justcode.BandTrackerLockQueue", attributes: [])
    fileprivate var bandSearchTasks : [URLSessionTask] = []
    
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
    
    func login(_ completionHandler: @escaping (_ error : String?) -> Void) {
       
        let postBody : [ String : AnyObject] = [
            "name"   : BandTrackerClient.USERNAME as AnyObject,
            "passwd" : BandTrackerClient.PASSWORD as AnyObject
        ]
        
        let _ = startTaskPOST(BandTrackerClient.BASE_URL, method: "auth/login", parameters: [:], jsonBody: postBody as AnyObject) { result, error in
            if let postResult = result as? NSDictionary {
                self.apiToken = postResult.value(forKey: "token") as? String
            }
            
            if let basicError = error as? NSError {
                completionHandler(BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? HTTPURLResponse {
                completionHandler(BandTrackerClient.formatHttpError(httpError))
            } else {
                completionHandler(nil);
            }
        }
        
    }
    
    func bandsFindByName(_ pattern : String, completionHandler: @escaping (_ bands : [BandTrackerClient.Band]?, _ error : String?, _ requestTimeStamp : TimeInterval) -> Void) {
        
        let timeStamp = Date.timeIntervalSinceReferenceDate
       
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(nil, error, timeStamp)
                } else {
                    self.bandsFindByName(pattern, completionHandler: completionHandler);
                }
            }
        }
        
        // configure request
        let parameters : [String : AnyObject] = [
            "name": pattern as AnyObject
        ]
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        // cancel any bandSearch tasks that haven't started uploading yet
        lockQueue.sync {
            for (idx, task) in self.bandSearchTasks.enumerated() {
                if (task.state == .running && task.countOfBytesSent == 0) || (task.state == .completed ) {
                    task.cancel()
                    self.bandSearchTasks.remove(at: idx)
                }
            }
        }
        
        // execute request
        let task = startTaskGET(BandTrackerClient.BASE_URL, method: "bands/find-by-name", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            
            // handle result
            if let basicError = error as? NSError {
                if basicError.code != NSURLErrorCancelled {
                    completionHandler(nil, BandTrackerClient.formatBasicError(basicError), timeStamp)
                }
            } else if let httpError = error as? HTTPURLResponse {
                completionHandler(nil, BandTrackerClient.formatHttpError(httpError), timeStamp)
            } else {
                let postResult = result as! [AnyObject];
                var bands : [BandTrackerClient.Band] = []
                
                for bandDictionary in postResult {
                    bands.append(BandTrackerClient.Band(values: bandDictionary as! [String : AnyObject]))
                }
                
                completionHandler(bands, nil, timeStamp)
            }
        }
        
        // store the task
        lockQueue.sync {
            if let task = task {
                self.bandSearchTasks.append(task)
            }
        }
    }
    
    func cityFind(_ pattern : String, countryCode : String?, completionHandler : @escaping (_ cities : [String]?, _ error : String?, _ requestTimeStamp : TimeInterval) -> Void) {
        
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(nil, error, 0)
                } else {
                    self.cityFind(pattern, countryCode: countryCode, completionHandler: completionHandler)
                }
            }
        }
        
        // configure request
        var parameters : [String : AnyObject] = [
            "pattern": pattern as AnyObject
        ]
        
        if let countryCode = countryCode {
            if !countryCode.isEmpty {
                parameters["country"] = countryCode as AnyObject
            }
        }
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        let timeStamp = Date.timeIntervalSinceReferenceDate
        
        // execute request
        let _ = startTaskGET(BandTrackerClient.BASE_URL, method: "city/find", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(nil, BandTrackerClient.formatBasicError(basicError), timeStamp)
            } else if let httpError = error as? HTTPURLResponse {
                completionHandler(nil, BandTrackerClient.formatHttpError(httpError), timeStamp)
            } else {
                let postResult = result as! [String]
                completionHandler(postResult, nil, timeStamp)
            }
        }
    }
    
    func venueFind(_ pattern : String, countryCode : String?, city : String?, completionHandler : @escaping (_ venues : [String]?, _ error : String?, _ requestTimeStamp : TimeInterval) -> Void)  {
        
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(nil, error, 0)
                } else {
                    self.venueFind(pattern, countryCode: countryCode, city: city, completionHandler: completionHandler)
                }
            }
        }
        
        // configure request
        var parameters : [String : AnyObject] = [
            "pattern": pattern as AnyObject
        ]
        
        if let countryCode = countryCode {
            if !countryCode.isEmpty {
                parameters["country"] = countryCode as AnyObject
            }
        }
        
        if let city = city {
            if !city.isEmpty {
                parameters["city"] = city as AnyObject
            }
        }
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        let timeStamp = Date.timeIntervalSinceReferenceDate
        
        // execute request
        let _ = startTaskGET(BandTrackerClient.BASE_URL, method: "venue/find", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(nil, BandTrackerClient.formatBasicError(basicError), timeStamp)
            } else if let httpError = error as? HTTPURLResponse {
                completionHandler(nil, BandTrackerClient.formatHttpError(httpError), timeStamp)
            } else {
                let postResult = result as! [String]
                completionHandler(postResult, nil, timeStamp)
            }
        }
    }
    
    func tourDateFind(_ bandMBID : String, dateFrom : Date?, dateTo : Date?, countryCode : String?, location : String?,
                      completionHandler : @escaping (_ tourDates : [BandTrackerClient.TourDate]?, _ error : String?, _ requestTimeStamp : TimeInterval) -> Void) {
       
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(nil, error, 0)
                } else {
                    self.tourDateFind(bandMBID, dateFrom: dateFrom, dateTo: dateTo, countryCode: countryCode, location: location, completionHandler: completionHandler)
                }
            }
        }
                        
        // configure request
        var parameters : [String : AnyObject] = [
            "band" : bandMBID as AnyObject
        ]
                        
        if let dateFrom = dateFrom {
            parameters["start"] = DateUtils.format(dateFrom, format: "yyyy-MM-dd") as AnyObject
        }
        
        if let dateTo = dateTo {
            parameters["end"] = DateUtils.format(dateTo, format: "yyyy-MM-dd") as AnyObject
        }
        
        if let countryCode = countryCode {
            parameters["country"] = countryCode as AnyObject
        }
        
        if let location = location {
            parameters["location"] = location as AnyObject
        }
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        let timeStamp = Date.timeIntervalSinceReferenceDate
        
        // execute request
        let _ = startTaskGET(BandTrackerClient.BASE_URL, method: "tourdate/find", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(nil, BandTrackerClient.formatBasicError(basicError), timeStamp)
            } else if let httpError = error as? HTTPURLResponse {
                completionHandler(nil, BandTrackerClient.formatHttpError(httpError), timeStamp)
            } else {
                let postResult = result as! [AnyObject];
                var tourDates : [TourDate] = []
                
                for dateDictionary in postResult {
                    if let tourDate = TourDate(values: dateDictionary as! [String : AnyObject]) {
                        tourDates.append(tourDate)
                    }
                }
                
                completionHandler(tourDates, nil, timeStamp)
            }
        }
    }
    
    func tourDateYears(_ bandMBID : String, completionHandler : @escaping (_ years : [Int]?, _ error : String?) -> Void) {
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(nil, error)
                } else {
                    self.tourDateYears(bandMBID, completionHandler: completionHandler)
                }
            }
        }
        
        // configure request
        let parameters : [String : AnyObject] = [
            "band": bandMBID as AnyObject
        ]
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        // execute request
        let _ = startTaskGET(BandTrackerClient.BASE_URL, method: "tourdate/band-years", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(nil, BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? HTTPURLResponse {
                completionHandler(nil, BandTrackerClient.formatHttpError(httpError))
            } else {
                let postResult = result as! [Int]
                completionHandler(postResult, nil)
            }
        }
        
    }
    
    func countrySync(_ syncId : Int, completionHandler : @escaping (_ syncId : Int, _ countries : [BandTrackerClient.Country]?, _ error : String?) -> Void) {
        
        // make sure to login first
        guard let token = apiToken else {
            return login() { error in
                if let error = error {
                    completionHandler(0, nil, error)
                } else {
                    self.countrySync(syncId, completionHandler: completionHandler)
                }
            }
        }
        
        // configure request
        let parameters : [String : AnyObject] = [
            "syncId": syncId as AnyObject
        ]
        
        let extraHeaders : [String : String] = [
            "x-access-token" : token
        ]
        
        // execute request
        let _ = startTaskGET(BandTrackerClient.BASE_URL, method: "country/sync", parameters : parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(0, nil, BandTrackerClient.formatBasicError(basicError))
            } else if let httpError = error as? HTTPURLResponse {
                completionHandler(0, nil, BandTrackerClient.formatHttpError(httpError))
            } else {
                let postResult = result as! NSDictionary
                var countries :  [BandTrackerClient.Country] = []
                
                for country in postResult.value(forKey: "countries") as! [[String : AnyObject]] {
                    countries.append(BandTrackerClient.Country(values: country))
                }
                
                completionHandler(postResult["sync"] as! Int, countries, nil);
                    
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
    
    static let instance = BandTrackerClient()
}

func bandTrackerClient() -> BandTrackerClient {
    return BandTrackerClient.instance
}
