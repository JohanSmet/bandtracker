//
//  AlertPopups.swift
//  On The Map
//
//  Created by Johan Smet on 08/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

func alertOkAsync(_ viewController : UIViewController, message : String, title : String? = nil) {
    
    DispatchQueue.main.async(execute: {
        let _ = alertOk(viewController, message: message, title: title)
    })
}

func alertOk(_ viewController : UIViewController, message : String, title : String? = nil) -> UIView {
    let alert = UIAlertController(title: title ?? NSLocalizedString("viewAttention", comment: "Attention"), message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("viewOk", comment: "OK"), style: UIAlertAction.Style.default, handler: nil))
    viewController.present(alert, animated: true, completion: nil)
    return alert.view
}
