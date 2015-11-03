//
//  GigGuidedCreationFilterController.swift
//  bandtracker
//
//  Created by Johan Smet on 29/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

protocol GigGuidedCreationFilterDelegate {
    func filterValueChanged(filterController : GigGuidedCreationFilterController)
}

class GigGuidedCreationFilterController : UITableViewController,
                                          UIPickerViewDataSource,
                                          UIPickerViewDelegate {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    private let ROW_YEAR_PICKER = 1
    private let ROW_COUNTRY     = 0
    
    private let HEIGHT_YEAR_PICKER : CGFloat = 162
    private let YEAR_PICKER_START = 1970
    private let YEAR_PICKER_COUNT = 100
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var selYear   : Int = 0
    var startDate : NSDate!
    var endDate   : NSDate!
    var country   : Country!
    var delegate  : GigGuidedCreationFilterDelegate!
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var textCountry: UITextField!
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yearPicker.dataSource = self
        yearPicker.delegate   = self
        
        // init values
        selYear = NSCalendar.currentCalendar().component(.Year, fromDate: NSDate())
        yearPicker.selectRow(selYear - YEAR_PICKER_START, inComponent: 0, animated: false)
        recomputeYearLimits()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == ROW_YEAR_PICKER {
            return HEIGHT_YEAR_PICKER
        }
        
        return self.tableView.rowHeight
    }
   
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // country selection
        if indexPath.row == ROW_COUNTRY {
            let countrySelect = ListSelectionController.create(CountrySelectionDelegate(initialFilter: textCountry.text!) { name in
                self.textCountry.text! = name
                self.country = dataContext().countryByName(name)
                self.delegateValueChanged()
            })
            
            navigationController?.pushViewController(countrySelect, animated: true)
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewPickerDataSource
    //
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return YEAR_PICKER_COUNT
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewPickerDelegate
    //
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + YEAR_PICKER_START)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selYear = row + YEAR_PICKER_START
        recomputeYearLimits()
        delegateValueChanged()
    }
 
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func recomputeYearLimits() {
        startDate = computeStartDate(selYear)
        endDate   = computeEndDate()
    }
    
    private func computeStartDate(year : Int) -> NSDate {
        let components = NSDateComponents()
        components.day   = 1
        components.month = 1
        components.year  = year
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
    
    private func computeEndDate() -> NSDate {
        let offset  = NSDateComponents()
        offset.day  = -1
        offset.year = 1
        return NSCalendar.currentCalendar().dateByAddingComponents(offset, toDate: startDate, options: [])!
    }
    
    private func delegateValueChanged() {
        if let delegate = delegate {
            delegate.filterValueChanged(self)
        }
    }
}
