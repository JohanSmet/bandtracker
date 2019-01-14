//
//  WebApiClient.swift
//  bandtracker
//
//  Created by Johan Smet on 19/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class WebApiClient {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    // shared session
    var urlSession : URLSession
    var dataOffset : Int = 0
    
    static var runningTasks = 0
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initializers
    //
    
    init() {
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    init(dataOffset : Int) {
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default)
        self.dataOffset = dataOffset
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // wrappers for GET-request
    //
    
    func startTaskGET(_ serverURL: String, method: String, parameters : [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void) -> URLSessionDataTask? {
        return startTaskHTTP("GET", serverURL: serverURL, apiMethod: method,
                             parameters: parameters, extraHeaders: [:], jsonBody: nil,
                             completionHandler: completionHandler)
    }
    
    func startTaskGET(_ serverURL: String, method: String, parameters : [String : AnyObject], extraHeaders : [String : String],
                      completionHandler: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void) -> URLSessionDataTask? {
        return startTaskHTTP("GET", serverURL: serverURL, apiMethod: method,
                             parameters: parameters, extraHeaders: extraHeaders, jsonBody: nil,
                             completionHandler: completionHandler)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // wrapper for POST-request
    //
    
    func startTaskPOST(_ serverURL: String, method: String, parameters : [String : AnyObject], jsonBody: AnyObject,
                       completionHandler: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void) -> URLSessionDataTask? {
        return startTaskHTTP("POST", serverURL: serverURL, apiMethod: method,
                             parameters: parameters, extraHeaders: [:], jsonBody: jsonBody,
                             completionHandler: completionHandler)
    }

    func startTaskPOST(_ serverURL: String, method: String, parameters : [String : AnyObject], extraHeaders: [String : String], jsonBody: AnyObject,
                       completionHandler: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void) -> URLSessionDataTask? {
        return startTaskHTTP("POST", serverURL: serverURL, apiMethod: method,
                             parameters: parameters, extraHeaders: extraHeaders, jsonBody: jsonBody,
                             completionHandler: completionHandler)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // wrapper for DELETE-request
    //
    
    func startTaskDELETE(_ serverURL : String, apiMethod : String, parameters : [String : AnyObject],
                         completionHandler: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void) -> URLSessionDataTask? {
        return startTaskHTTP("DELETE", serverURL: serverURL, apiMethod: apiMethod,
                             parameters: parameters, extraHeaders: [:], jsonBody: nil,
                             completionHandler: completionHandler)
    }
    
    func startTaskDELETE(_ serverURL : String, apiMethod : String, parameters : [String : AnyObject], extraHeaders: [String : String],
                         completionHandler: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void) -> URLSessionDataTask? {
        return startTaskHTTP("DELETE", serverURL: serverURL, apiMethod: apiMethod,
                             parameters: parameters, extraHeaders: extraHeaders, jsonBody: nil,
                             completionHandler: completionHandler)
    }
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // generic HTTP-request
    //
    
    func startTaskHTTP(_ httpMethod : String, serverURL: String, apiMethod: String, parameters : [String : AnyObject], extraHeaders: [String : String], jsonBody: AnyObject?,
        completionHandler: @escaping (_ result: AnyObject?, _ error: AnyObject?) -> Void) -> URLSessionDataTask? {
            
            // build the url
            let url = URL(string: serverURL + apiMethod + WebApiClient.formatURLParameters(parameters))!
            
            // configure the request
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
           
            // headers
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            for (hKey, hValue) in extraHeaders {
                request.addValue(hValue, forHTTPHeaderField: hKey)
            }
            
            // optional body
            if let jsonBody: AnyObject = jsonBody {
                
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: jsonBody, options: JSONSerialization.WritingOptions.prettyPrinted)
                } catch let error as NSError {
                    completionHandler(nil, String.localizedStringWithFormat(NSLocalizedString("cliInternalJsonError", comment:"Internal error : invalid jsonBody (error: %s)"), error) as AnyObject)
                    return nil                              // exit !!!
                }
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            WebApiClient.startingTask()
            
            // submit the request
            let task = urlSession.dataTask(with: request, completionHandler: { data, response, urlError in
                
                defer { WebApiClient.endingTask() }
                
                // check for basic connectivity errors
                if let error = urlError {
                    completionHandler(nil, error as AnyObject)
                    return
                }
                
                // check for HTTP errors
                if let httpResponse = response as? HTTPURLResponse {
                    if WebApiClient.httpStatusIsError(httpResponse.statusCode) {
                        completionHandler(nil, httpResponse)
                        return
                    }
                }
                
                // parse the JSON
                do {
                    let parseResult: AnyObject! = try WebApiClient.parseJSON(data!.subdata(in: self.dataOffset ..< data!.count - self.dataOffset))
                    completionHandler(parseResult, nil)
                } catch let error as NSError {
                    completionHandler(nil, error)
                }
            }) 
            
            // submit the request to the server
            task.resume()
            
            return task
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    fileprivate class func formatURLParameters(_ parameters : [String : AnyObject]) -> String {
     
        var result = ""
        var delim  = "?"
        
        for (key, value) in parameters {
            
            // be sure to convert to a string
            let stringValue = "\(value)"
            
            // escape the value
            let escValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            // append to the result
            result += delim + key + "=" + "\(escValue!)"
            delim = "&"
        }
        
        return result;
    }
    
    fileprivate class func parseJSON(_ data : Data) throws -> AnyObject! {
        let parsedResult : Any? = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        return parsedResult as AnyObject?
    }
    
    fileprivate class func httpStatusIsError(_ statusCode : Int) -> Bool {
        
        return statusCode >= 400
        
    }
    
    fileprivate class func startingTask() {
        
        DispatchQueue.main.async {
            runningTasks += 1
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    fileprivate class func endingTask() {
        
        DispatchQueue.main.async {
            runningTasks -= 1
            UIApplication.shared.isNetworkActivityIndicatorVisible = runningTasks > 0
        }
    }
    
    
}
