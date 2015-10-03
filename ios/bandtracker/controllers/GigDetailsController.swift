//
//  GigDetailsController.swift
//  bandtracker
//
//  Created by Johan Smet on 30/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class GigDetailsController :    UIPageViewController,
                                UIPageViewControllerDataSource {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    let pageIDs : [String] = [
        "GigDetailsDataController",
        "GigDetailsSetlistController",
        "GigDetailsYoutubeController"
    ]
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init page controller
        self.dataSource = self
        
        // create the initial view
        let page = pageViewControllerForIndex(0)
        setViewControllers([page!], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // customize the page control
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.whiteColor()
        
        let buttonSave = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: "saveGig")
        self.navigationItem.setRightBarButtonItems([buttonSave], animated: false)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func saveGig() {
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIPageViewControllerDataSource
    //
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let pageIndex = self.pageIDs.indexOf(viewController.restorationIdentifier!)!
        
        if pageIndex <= 0 {
            return nil
        }
        
        return pageViewControllerForIndex(pageIndex - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let pageIndex = self.pageIDs.indexOf(viewController.restorationIdentifier!)!
        
        if pageIndex >= pageIDs.count {
            return nil
        }
        
        return pageViewControllerForIndex(pageIndex + 1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageIDs.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    func pageViewControllerForIndex(index : Int) -> UIViewController? {
       
        if index < 0 || index >= self.pageIDs.count {
            return nil
        }
        
        return self.storyboard?.instantiateViewControllerWithIdentifier(pageIDs[index])
        
    }
    
}