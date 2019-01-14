//
//  KeyboardFix.swift
//  bandtracker
//
//  Created by Johan Smet on 03/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class KeyboardFix : NSObject {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    fileprivate let viewController : UIViewController
    fileprivate let scrollView     : UIScrollView!
    
    fileprivate var activeControl   : UIView?
    fileprivate var tapRecognizer   : UITapGestureRecognizer?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    init (viewController : UIViewController, scrollView : UIScrollView! = nil) {
        
        self.viewController = viewController
        self.scrollView     = scrollView
        super.init()
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //
    
    func activate() {
        // keyboard notifications
        subscribeToKeyboardNotifications()
        
        // hide keyboard when the view is tapped
        if tapRecognizer == nil {
            tapRecognizer = UITapGestureRecognizer(target: self, action : #selector(KeyboardFix.handleTap))
            tapRecognizer?.numberOfTapsRequired = 1
        }
    }
    
    func deactivate() {
        unsubscribeFromKeyboardNotifications()
    }
    
    func setActiveControl(_ control : UIView?) {
        self.activeControl = control
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // scroll the view when the keyboard (dis)appears
    //
    
    fileprivate func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardFix.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardFix.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        // keyboard height
        let kbHeight = getKeyboardHeight(notification)
        
        // update the insets of the scroll view
        if let scrollView = scrollView {
            let contentInsets:UIEdgeInsets   = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0)
            scrollView.contentInset          = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        
            // check if the current control is outside the view or not
            if let activeControl = self.activeControl {
                
                var aRect: CGRect = viewController.view.frame
                aRect.size.height -= kbHeight
                
                if (!aRect.contains(activeControl.frame.origin) ) {
                    let scrollPoint:CGPoint = CGPoint(x: 0.0, y: activeControl.frame.origin.y - kbHeight)
                    scrollView.setContentOffset(scrollPoint, animated: true)
                }
            }
        }
        
        // hide keyboard when the view is tapped
        viewController.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        viewController.view.removeGestureRecognizer(tapRecognizer!)
        
        // reset insets
        if let scrollView = scrollView {
            let contentInsets:UIEdgeInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    fileprivate func getKeyboardHeight(_ notification : Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // tap recognizer
    //
    
    func handleTap() {
        // viewController.view.endEditing(true)
        viewController.view.window?.endEditing(true)
    }
}
