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
    
    private let ROW_YEAR_PICKER = 0
    private let ROW_COUNTRY     = 1
    
    private let HEIGHT_YEAR_PICKER : CGFloat = 162
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var selYear   : Int = 0
    var years     : [Int] = [] {
        didSet {
            guard let picker = self.yearPicker else { return }
            
            picker.reloadComponent(0)
            setDefaultYear()
        }
    }
    
    var band      : Band!
    
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
        
        // init delegates
        yearPicker.dataSource = self
        yearPicker.delegate   = self
        
        // set defaults
        if !loadDefaults() {
            setDefaultYear()
        }
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
                self.saveDefaults()
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
        return years.count
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewPickerDelegate
    //
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(years[row])"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selYear = years[row]
        recomputeYearLimits()
        saveDefaults()
        delegateValueChanged()
    }
 
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func setDefaultYear() {
        if !years.isEmpty {
            yearPicker.selectRow(years.count - 1, inComponent: 0, animated: false)
            selYear = years.last!
            recomputeYearLimits()
            delegateValueChanged()
        }
    }
    
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
    
    private func loadDefaults() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults();
        
        // load defaults if band is still the same as last time
        guard let bandId = defaults.stringForKey("guidedGigBand") else { return false }
        
        if bandId != band.bandMBID {
            return false
        }
        
        let defYear     = defaults.integerForKey("guidedGigYear")
        let defCountry  = defaults.stringForKey("guidedGigCountry") ?? ""
        
        for (idx, year) in years.enumerate() {
            if year >= defYear {
                yearPicker.selectRow(idx, inComponent: 0, animated: false)
                selYear = year
                recomputeYearLimits()
                break
            }
        }
        
        if !defCountry.isEmpty {
            country = dataContext().countryByCode(defCountry)
            textCountry.text = country.name
        }
        
        delegateValueChanged()
        return true
    }
    
    private func saveDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults();
        
        defaults.setObject(band.bandMBID,   forKey: "guidedGigBand")
        defaults.setInteger(selYear,        forKey: "guidedGigYear")
        
        if let country = country {
            defaults.setObject(country.code, forKey: "guidedGigCountry")
        } else {
            defaults.setObject("", forKey: "guidedGigCountry")
        }
    }
}
