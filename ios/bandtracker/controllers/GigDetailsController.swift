//
//  GigDetailsController.swift
//  bandtracker
//
//  Created by Johan Smet on 30/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum GigDetailsControllerMode {
    case Create
    case Edit
    case View
}

protocol GigDetailsSubViewDelegate {
    func enableSave(enable : Bool)
    func switchToYoutubePage(song : String)
    func youtubeSong() -> String!
}

protocol GigDetailsSubView {
    var gig : Gig! {get set}
    var delegate : GigDetailsSubViewDelegate! {get set}
    func setEditableControls(edit : Bool)
}

class GigDetailsController :    UIPageViewController,
                                UIPageViewControllerDataSource,
                                UIPageViewControllerDelegate,
                                GigDetailsSubViewDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    let pageIDs : [String] = [
        "GigDetailsDataContainer",
        "GigDetailsSetlistController",
        "GigDetailsYoutubeController"
    ]
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var mode            : GigDetailsControllerMode!
    var scratchContext  : NSManagedObjectContext = coreDataStackManager().childObjectContext()
    var gig             : Gig!
    var song            : String!
    
    var pages   : [GigDetailsSubView!] = [nil, nil, nil]
    var curPage : Int = 0
    var nextPage: Int = 0
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // class functions
    //
    
    class func createNewGig(band : Band) -> GigDetailsController {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewControllerWithIdentifier("GigDetailsController") as! GigDetailsController
        newVC.mode      = .Create
        newVC.gig       = Gig(band: newVC.scratchContext.objectWithID(band.objectID) as! Band, context: newVC.scratchContext)
        
        return newVC
    }
    
    class func displayGig(gig : Gig) -> GigDetailsController {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewControllerWithIdentifier("GigDetailsController") as! GigDetailsController
        newVC.mode = .View
        newVC.gig  = newVC.scratchContext.objectWithID(gig.objectID) as! Gig
        
        return newVC
    }
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init page controller
        self.dataSource = self
        self.delegate   = self
        
        // initialize gig-record
        gig.prepareForEdit()
        
        // create the initial view
        let page = pageViewControllerForIndex(0)
        setViewControllers([page!], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        // configure navigation controller
        createNavigationButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // customize the page control
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.whiteColor()
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // GigDetailsSubviewDelegate
    //
    
    func enableSave(enable : Bool) {
        if mode != .View {
            navigationItem.rightBarButtonItem?.enabled = enable
        }
    }
    
    func switchToYoutubePage(song : String) {
        self.song = song
        self.curPage = 2
        
        let page = pageViewControllerForIndex(2)
        setViewControllers([page!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    func youtubeSong() -> String! {
        let result = song
        song = nil
        return result
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func saveGig() {
        if let gig = gig {
            gig.processEdit()
            
            coreDataStackManager().saveChildContext(scratchContext)
            coreDataStackManager().saveContext()
            
            gig.band.totalRating = dataContext().totalRatingOfGigs(gig.band)
            coreDataStackManager().saveContext()
            
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func editGig() {
        mode = .Edit
        createNavigationButtons()
        
        for page in pages {
            if let page = page {
                page.setEditableControls(true)
            }
        }
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
        return curPage
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIPageViewControllerDelegate
    //
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
       
        curPage = (pageViewController.viewControllers?[0].view.tag)!
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    func pageViewControllerForIndex(index : Int) -> UIViewController? {
       
        if index < 0 || index >= self.pageIDs.count {
            return nil
        }
        
        if let page = pages[index] {
            return page as? UIViewController
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(pageIDs[index])
        
        var page = vc as! GigDetailsSubView
        page.gig = gig
        page.delegate = self
        page.setEditableControls(self.mode! != .View)
        vc!.view.tag = index
        
        pages[index] = page
        
        return vc
    }
    
    func createNavigationButtons() {
        switch (self.mode!) {
            case .Create :
                let buttonSave = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: "saveGig")
                buttonSave.enabled = false
                self.navigationItem.setRightBarButtonItems([buttonSave], animated: false)
                
            case .View :
                let buttonEdit = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editGig")
                self.navigationItem.setRightBarButtonItems([buttonEdit], animated: false)
                
            case .Edit :
                let buttonSave = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "saveGig")
                self.navigationItem.setRightBarButtonItems([buttonSave], animated: false)
        }
    }
    
}