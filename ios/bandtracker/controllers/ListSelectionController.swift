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
    
    func numberOfSections(_ listSelectionController : ListSelectionController) -> Int
    func titleForSection(_ listSelectionController : ListSelectionController, section : Int) -> String?
    func dataForSection(_ listSelectionController : ListSelectionController, section : Int, filterText : String, completionHandler : @escaping (_ data  : [AnyObject]?) -> Void)
    func configureCellForItem(_ listSelectionController : ListSelectionController, cell : UITableViewCell, section : Int, item : AnyObject)
    
    func didSelectItem(_ listSelectionController : ListSelectionController, custom : Bool, section : Int, item : AnyObject)
    
}


class ListSelectionController : UIViewController,
                                UITextFieldDelegate,
                                UITableViewDataSource,
                                UITableViewDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    fileprivate var delegate        : ListSelectionControllerDelegate!
    fileprivate var numSections     : Int = 0
    fileprivate var selectionData   : [[AnyObject]] = []
    
    fileprivate var keyboardFix     : KeyboardFix?
   
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
    
    class func create(_ delegate : ListSelectionControllerDelegate) -> ListSelectionController {
        
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ListSelectionController") as! ListSelectionController
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
            filterText.isHidden      = true
        }
        
        // table sections
        numSections = delegate.numberOfSections(self)

        for _ in 0 ..< numSections {
            selectionData.append([])
        }
        
        // tableview
        tableView.dataSource = self
        tableView.delegate   = self
        
        keyboardFix = KeyboardFix(viewController: self, scrollView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refilterData(filterText.text!)
        
        // handle keyboard properly
        if let keyboardFix = self.keyboardFix {
            keyboardFix.activate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let keyboardFix = self.keyboardFix {
            keyboardFix.deactivate()
        }
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        TableViewUtils.messageEmptyTable(tableView, isEmpty: !filterText.text!.isEmpty && !sectionsHaveData() && !delegate.enableCustomValue,
                                         message: NSLocalizedString("conNoResults", comment: "No Results"))
        return numSections + (delegate.enableCustomValue ? 1 : 0)
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if delegate.enableCustomValue && section == 0 {
            return 1
        }
        
        return dataForSection(section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: delegate.cellType, for: indexPath)
        
        if delegate.enableCustomValue && indexPath.section == 0 {
            cell.textLabel?.text = filterText.text
        } else {
            let delta = delegate.enableCustomValue ? 1 : 0
            delegate.configureCellForItem(self, cell: cell, section: indexPath.section - delta, item: itemForIndexPath(indexPath))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if delegate.enableCustomValue && indexPath.section == 0 {
            delegate.didSelectItem(self, custom: true, section: 0, item: filterText.text! as AnyObject)
        } else {
            let delta = delegate.enableCustomValue ? 1 : 0
            delegate.didSelectItem(self, custom: false, section: indexPath.section - delta, item: itemForIndexPath(indexPath))
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate
    //
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newText : NSString = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        textField.text = newText as String
        
        refilterData(textField.text!)
        tableView.reloadData()
        
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        refilterData("")
        tableView.reloadData()
        return true
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    fileprivate func refilterData(_ filter : String) {
        
        for section in 0 ..< numSections {
            delegate.dataForSection(self, section: section, filterText: filter) { data in
                
                DispatchQueue.main.async {
                    self.selectionData[section] = data ?? []
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    fileprivate func dataForSection(_ section : Int) -> [AnyObject] {
        let delta = delegate.enableCustomValue ? 1 : 0
        return selectionData[section - delta]
    }
    
    fileprivate func itemForIndexPath(_ indexPath : IndexPath) -> AnyObject {
        let delta = delegate.enableCustomValue ? 1 : 0
        return selectionData[indexPath.section - delta][indexPath.row]
    }
    
    fileprivate func sectionsHaveData() -> Bool {
       
        for data in selectionData {
            if !data.isEmpty {
                return true
            }
        }
        
        return false
        
    }
    
}
