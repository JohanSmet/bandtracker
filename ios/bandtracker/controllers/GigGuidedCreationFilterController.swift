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
    func filterValueChanged(_ filterController : GigGuidedCreationFilterController)
}

class GigGuidedCreationFilterController : UITableViewController,
                                          UIPickerViewDataSource,
                                          UIPickerViewDelegate {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    fileprivate let ROW_YEAR_PICKER = 0
    fileprivate let ROW_COUNTRY     = 1
    
    fileprivate let HEIGHT_YEAR_PICKER : CGFloat = 162
    
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
    
    var startDate : Date!
    var endDate   : Date!
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == ROW_YEAR_PICKER {
            return HEIGHT_YEAR_PICKER
        }
        
        return self.tableView.rowHeight
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewPickerDelegate
    //
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(years[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selYear = years[row]
        recomputeYearLimits()
        saveDefaults()
        delegateValueChanged()
    }
 
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    fileprivate func setDefaultYear() {
        if !years.isEmpty {
            yearPicker.selectRow(years.count - 1, inComponent: 0, animated: false)
            selYear = years.last!
            recomputeYearLimits()
            delegateValueChanged()
        }
    }
    
    fileprivate func recomputeYearLimits() {
        startDate = computeStartDate(selYear)
        endDate   = computeEndDate()
    }
    
    fileprivate func computeStartDate(_ year : Int) -> Date {
        var components = DateComponents()
        components.day   = 1
        components.month = 1
        components.year  = year
        return Calendar.current.date(from: components)!
    }
    
    fileprivate func computeEndDate() -> Date {
        var offset  = DateComponents()
        offset.day  = -1
        offset.year = 1
        return (Calendar.current as NSCalendar).date(byAdding: offset, to: startDate, options: [])!
    }
    
    fileprivate func delegateValueChanged() {
        if let delegate = delegate {
            delegate.filterValueChanged(self)
        }
    }
    
    fileprivate func loadDefaults() -> Bool {
        let defaults = UserDefaults.standard;
        
        // load defaults if band is still the same as last time
        guard let bandId = defaults.string(forKey: "guidedGigBand") else { return false }
        
        if bandId != band.bandMBID {
            return false
        }
        
        let defYear     = defaults.integer(forKey: "guidedGigYear")
        let defCountry  = defaults.string(forKey: "guidedGigCountry") ?? ""
        
        for (idx, year) in years.enumerated() {
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
    
    fileprivate func saveDefaults() {
        let defaults = UserDefaults.standard;
        
        defaults.set(band.bandMBID,   forKey: "guidedGigBand")
        defaults.set(selYear,        forKey: "guidedGigYear")
        
        if let country = country {
            defaults.set(country.code, forKey: "guidedGigCountry")
        } else {
            defaults.set("", forKey: "guidedGigCountry")
        }
    }
}
