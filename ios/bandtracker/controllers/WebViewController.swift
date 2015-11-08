//
//  WebViewController.swift
//  bandtracker
//
//  Created by Johan Smet on 08/11/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class WebViewController : UIViewController {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var request : NSURLRequest?
    var text    : String?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var webView: UIWebView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // class functions
    //
    
    class func create(forString text : String) -> WebViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let newVC = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        newVC.text = text
        
        return newVC
    }
    
    class func create(forResource resourceName : String) -> WebViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        
        let localResource = NSBundle.mainBundle().URLForResource(resourceName, withExtension: "html")
        newVC.request = NSURLRequest(URL: localResource!)
        
        return newVC
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let request = request {
            webView.loadRequest(request)
        } else if let text = text {
            webView.loadHTMLString(text, baseURL: nil)
        }
    }
    
}