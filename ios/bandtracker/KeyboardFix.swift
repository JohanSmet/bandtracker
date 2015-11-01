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
    
    private let viewController : UIViewController
    private let scrollView     : UIScrollView!
    
    private var activeControl   : UIView?
    private var tapRecognizer   : UITapGestureRecognizer?
    
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
            tapRecognizer = UITapGestureRecognizer(target: self, action : "handleTap")
            tapRecognizer?.numberOfTapsRequired = 1
        }
    }
    
    func deactivate() {
        unsubscribeFromKeyboardNotifications()
    }
    
    func setActiveControl(control : UIView?) {
        self.activeControl = control
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // scroll the view when the keyboard (dis)appears
    //
    
    private func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
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
                
                if (!CGRectContainsPoint(aRect, activeControl.frame.origin) ) {
                    let scrollPoint:CGPoint = CGPointMake(0.0, activeControl.frame.origin.y - kbHeight)
                    scrollView.setContentOffset(scrollPoint, animated: true)
                }
            }
        }
        
        // hide keyboard when the view is tapped
        viewController.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        viewController.view.removeGestureRecognizer(tapRecognizer!)
        
        // reset insets
        if let scrollView = scrollView {
            let contentInsets:UIEdgeInsets = UIEdgeInsetsZero
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    private func getKeyboardHeight(notification : NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
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
