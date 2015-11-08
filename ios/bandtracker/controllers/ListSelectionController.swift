//
//  ListSelectionController.swift
//  bandtracker
//
//  Created by Johan Smet on 08/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

protocol ListSelectionControllerDelegate {
   
    var enableFilter        : Bool   { get }
    var enableCustomValue   : Bool   { get }
    var filterPlaceHolder   : String { get }
    var filterInitialValue  : String { get }
    var cellType            : String { get }
    
    func numberOfSections(listSelectionController : ListSelectionController) -> Int
    func titleForSection(listSelectionController : ListSelectionController, section : Int) -> String?
    func dataForSection(listSelectionController : ListSelectionController, section : Int, filterText : String, completionHandler : (data  : [AnyObject]?) -> Void)
    func configureCellForItem(listSelectionController : ListSelectionController, cell : UITableViewCell, section : Int, item : AnyObject)
    
    func didSelectItem(listSelectionController : ListSelectionController, custom : Bool, section : Int, item : AnyObject)
    
}


class ListSelectionController : UIViewController,
                                UITextFieldDelegate,
                                UITableViewDataSource,
                                UITableViewDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private var delegate        : ListSelectionControllerDelegate!
    private var numSections     : Int = 0
    private var selectionData   : [[AnyObject]] = []
   
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
    
    class func create(delegate : ListSelectionControllerDelegate) -> ListSelectionController {
        
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ListSelectionController") as! ListSelectionController
        vc.delegate = delegate
        
        return vc
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let delegate = delegate else { return }
        
        // filter
        if delegate.enableFilter {
            filterText.delegate    = self
            filterText.placeholder = delegate.filterPlaceHolder
            filterText.text        = delegate.filterInitialValue
        } else {
            filterText.hidden      = true
        }
        
        // table sections
        numSections = delegate.numberOfSections(self)

        for _ in 0 ..< numSections {
            selectionData.append([])
        }
        
        // tableview
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refilterData(filterText.text!)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numSections + (delegate.enableCustomValue ? 1 : 0)
    }
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if delegate.enableCustomValue && section == 0 {
            return 1
        }
        
        return dataForSection(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(delegate.cellType, forIndexPath: indexPath)
        
        if delegate.enableCustomValue && indexPath.section == 0 {
            cell.textLabel?.text = filterText.text
        } else {
            let delta = delegate.enableCustomValue ? 1 : 0
            delegate.configureCellForItem(self, cell: cell, section: indexPath.section - delta, item: itemForIndexPath(indexPath))
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if delegate.enableCustomValue && section == 0 {
            return nil
        }
        
        let delta = delegate.enableCustomValue ? 1 : 0
        if selectionData[section - delta].count > 0 {
            return delegate.titleForSection(self, section: section - delta)
        }
        
        return nil
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if delegate.enableCustomValue && indexPath.section == 0 {
            delegate.didSelectItem(self, custom: true, section: 0, item: filterText.text!)
        } else {
            let delta = delegate.enableCustomValue ? 1 : 0
            delegate.didSelectItem(self, custom: false, section: indexPath.section - delta, item: itemForIndexPath(indexPath))
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate
    //
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var newText : NSString = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        textField.text = newText as String
        
        refilterData(textField.text!)
        tableView.reloadData()
        
        return false
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        refilterData("")
        tableView.reloadData()
        return true
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func refilterData(filter : String) {
        
        for section in 0 ..< numSections {
            delegate.dataForSection(self, section: section, filterText: filter) { data in
                self.selectionData[section] = data ?? []
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    private func dataForSection(section : Int) -> [AnyObject] {
        let delta = delegate.enableCustomValue ? 1 : 0
        return selectionData[section - delta]
    }
    
    private func itemForIndexPath(indexPath : NSIndexPath) -> AnyObject {
        let delta = delegate.enableCustomValue ? 1 : 0
        return selectionData[indexPath.section - delta][indexPath.row]
    }
    
}