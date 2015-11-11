//
//  NavigationUtils.swift
//  bandtracker
//
//  Created by Johan Smet on 11/11/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class NavigationUtils {

    class func replaceViewController(navigationController : UINavigationController, newViewController newVC : UIViewController) {
        // replace the current controller with the new controller
        var controllerStack = navigationController.viewControllers
        controllerStack.removeAtIndex(controllerStack.count - 1)
        controllerStack.append(newVC)
        navigationController.setViewControllers(controllerStack, animated: true)
    }
}