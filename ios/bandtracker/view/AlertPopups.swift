//
//  AlertPopups.swift
//  On The Map
//
//  Created by Johan Smet on 08/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

func alertOkAsync(viewController : UIViewController, message : String, title : String? = nil) {
    
    dispatch_async(dispatch_get_main_queue(), {
        alertOk(viewController, message: message, title: title)
    })
}

func alertOk(viewController : UIViewController, message : String, title : String? = nil) -> UIView {
    let alert = UIAlertController(title: title ?? NSLocalizedString("viewAttention", comment: "Attention"), message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("viewOk", comment: "OK"), style: UIAlertActionStyle.Default, handler: nil))
    viewController.presentViewController(alert, animated: true, completion: nil)
    return alert.view
}