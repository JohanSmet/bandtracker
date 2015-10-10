//
//  ListSelectionController.swift
//  bandtracker
//
//  Created by Johan Smet on 08/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class ListSelectionController : UIViewController,
                                UITextFieldDelegate,
                                UITableViewDataSource,
                                UITableViewDelegate {
    
    
    typealias FilterCallbackType  = (filterText : String) -> [AnyObject]
    typealias DisplayCallbackType = (item : AnyObject) -> String
    typealias SelectCallbackType  = (custom : Bool, item : AnyObject) -> Void
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private var enableFilter : Bool = false
    private var enableCustom : Bool = false
    
    private var filterPlaceholder : String = ""
    private var filterInitial     : String = ""
    private var selectionData   : [AnyObject] = []
    
    private var filterCallback  : FilterCallbackType!
    private var displayCallback : DisplayCallbackType!
    private var selectCallback  : SelectCallbackType!
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var filterText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // interface to create a selection list
    //
    
    class func create(withFilter filterPlaceholder : String, initialFilter filterInitial : String, enableCustom : Bool,
                      filterCallback : FilterCallbackType, displayCallback : DisplayCallbackType, selectCallback : SelectCallbackType) -> ListSelectionController {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ListSelectionController") as! ListSelectionController
        
        vc.enableFilter = true
        vc.filterPlaceholder = filterPlaceholder
        vc.filterInitial     = filterInitial
        vc.enableCustom = enableCustom
        
        vc.filterCallback  = filterCallback
        vc.displayCallback = displayCallback
        vc.selectCallback  = selectCallback
        
        return vc
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterText.delegate = self
        filterText.placeholder = filterPlaceholder
        filterText.text        = filterInitial
        
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let callback = filterCallback {
            selectionData = callback(filterText: filterText.text!)
            tableView.reloadData()
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 + (enableCustom ? 1 : 0)
    }
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if enableCustom && section == 0 {
            return 1
        }
        
        return selectionData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectionCell", forIndexPath: indexPath)
        
        if enableCustom && indexPath.section == 0 {
            cell.textLabel?.text = filterText.text
        } else {
            cell.textLabel?.text = displayCallback(item: selectionData[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if enableCustom && section == 1 && selectionData.count > 0 {
            return "Matches"
        }
        
        return nil
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
        if enableCustom && indexPath.section == 0 && selectCallback != nil {
            selectCallback(custom: true, item: filterText.text!)
        } else {
            selectCallback(custom: false, item: selectionData[indexPath.row])
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate
    //
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var newText : NSString = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        textField.text = newText as String
        
        var doReload : Bool = enableCustom
        
        // update selection list
        if let callback = filterCallback {
            selectionData = callback(filterText: newText as String)
            doReload = true
        }
        
        if doReload {
            tableView.reloadData()
        }
        
        return false
    }
    
    
}