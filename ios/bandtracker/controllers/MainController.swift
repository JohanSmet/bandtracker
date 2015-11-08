//
//  MainController.swift
//  bandtracker
//
//  Created by Johan Smet on 20/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

protocol MainTabSheet {
    func updateSearchResults(searchText : String)
    func addNewItem();
    
    var searchBarVisible : Bool { get }
    var addButtonVisible : Bool { get }
}

class MainController:   UITabBarController,
                        UITabBarControllerDelegate,
                        UISearchResultsUpdating,
                        UISearchControllerDelegate {
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var searchController : UISearchController! = nil
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet var buttonAdd: UIBarButtonItem!
    @IBOutlet var buttonMore: UIBarButtonItem!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBAction func actionMore(sender: AnyObject) {
       
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let helpAction = UIAlertAction(title: "Help", style: .Default) { action in
            let vc = WebViewController.create(forString: "<html><body>Help</body></html>")
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
        let licenseAction = UIAlertAction(title: "View licenses", style: .Default) { action in
            let vc = WebViewController.create(forResource: "licenses")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {action in
        }
        
        alertController.addAction(helpAction)
        alertController.addAction(licenseAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make sure core data can be initialised properly
        if coreDataStackManager().managedObjectContext == nil {
            alertOk(self, message: NSLocalizedString("conCoreDataError", comment: "Unable to initalize CoreData-backend"))
            return
        }
        
        // sync data
        DataLoader.loadCountries() { error in
        }
        
        // create search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Filter"
        navigationItem.titleView = searchController.searchBar
        
        self.delegate = self
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let tab = viewController as? MainTabSheet {
            searchController.searchBar.hidden = !tab.searchBarVisible
            
            var rightBarItems : [UIBarButtonItem] = [buttonMore]
            
            if (tab.addButtonVisible) {
                rightBarItems.append(buttonAdd)
            }
            
            navigationItem.setRightBarButtonItems(rightBarItems, animated: false)
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UISearchResultsUpdating
    //
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let tab = self.selectedViewController as? MainTabSheet {
            tab.updateSearchResults(searchController.searchBar.text!)
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UISearchControllerDelegate
    //
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func addSeenBand(sender: UIBarButtonItem) {
        if let tab = self.selectedViewController as? MainTabSheet {
            tab.addNewItem()
        }
    }
}

