//
//  GigDetailsDataController.swift
//  bandtracker
//
//  Created by Johan Smet on 30/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class GigDetailsDataController : UITableViewController,
                                 UITextFieldDelegate,
                                 RatingControlDelegate,
                                 GigDetailsSubView {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
   
    let SECTION_DATES = 0
    let SECTION_META  = 1
    
    let ROW_COUNTRY   = 0
    let ROW_CITY      = 1
    let ROW_VENUE     = 2
    
    let START_DATE = 0
    let START_TIME = 1
    let DURATION   = 2
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var gig      : Gig!
    var delegate : GigDetailsSubViewDelegate!
    
    var datePickerRows      : [Int]  = [1, 3, 5]
    var datePickerEditing   : [Bool] = [false, false, false]
    var datePickerHeight    : CGFloat = 0
    
    var editable            : Bool = false
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet var datePickers : [UIView]!
    @IBOutlet var dateLabels  : [UILabel]!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var durationPicker: TimeIntervalPicker!
    
    @IBOutlet weak var textCountry: UITextField!
    @IBOutlet weak var textCity: UITextField!
    @IBOutlet weak var textVenue: UITextField!
    @IBOutlet weak var textStage: UITextField!
    
    @IBOutlet weak var switchSupportAct: UISwitch!
    @IBOutlet weak var ratingControl: RatingControl!
    
    @IBOutlet weak var textComments: UITextField!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // save the default height of a datepicker
        datePickerHeight = datePickers[0].bounds.height
        
        // set delegates
        textCountry.delegate    = self
        textCity.delegate       = self
        textVenue.delegate      = self
        textStage.delegate      = self
        textComments.delegate   = self
        ratingControl.delegate  = self
        
        setEditableControls(editable)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIFields()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // GigDetailsSubView
    //
    
    func setEditableControls(edit: Bool) {
        editable = edit
        
        if let _ = switchSupportAct {
            switchSupportAct.enabled    = editable
            textStage.enabled           = editable
            textComments.enabled        = editable
            ratingControl.enabled       = editable
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func pickStartChanged(sender: UIDatePicker) {
        gig.startDate = DateUtils.join(startDatePicker.date, time: startTimePicker.date)
        updateStartLabels()
        validateForm()
    }
    
    @IBAction func pickDurationChanged(sender: TimeIntervalPicker) {
        gig.endDate = DateUtils.add(gig.startDate, interval: durationPicker.timeInterval)
        updateEndLabels()
        validateForm()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate
    //
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == textCountry {
            gig.editCountry = textField.text!
        } else if textField == textCity {
            gig.editCity = textField.text!
        } else if textField == textVenue {
            gig.editVenue = textField.text!
        } else if textField == textStage {
            gig.stage = textField.text!
        } else if textField == textComments {
            gig.comments = textField.text!
        }
        
        validateForm()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // RatingControlDelegate
    //
    
    func ratingDidChange(ratingControl: RatingControl, newRating: Float, oldRating: Float) {
        gig.rating = Int(newRating * 10)
        validateForm()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == SECTION_DATES {
            if let index = datePickerRows.indexOf(indexPath.row) {
                return self.datePickerEditing[index] ? datePickerHeight : 0
            }
        }
        
        return self.tableView.rowHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var doReload = false
        
        if !editable {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return
        }
        
        if indexPath.section == SECTION_DATES {
            if let index = datePickerRows.indexOf(indexPath.row + 1) {
                togglePicker(index)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                doReload = true
            }
        }
        else if indexPath.section == SECTION_META && indexPath.row == ROW_COUNTRY {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let countrySelect = ListSelectionController.create(withFilter: "Enter country", initialFilter: gig.editCountry, enableCustom: false,
                filterCallback : { filterText in
                    return dataContext().countryList(filterText)
                },
                displayCallback : { item in
                    return (item as? Country)!.name
                },
                selectCallback : { custom, item in
                    if let country = item as? Country {
                        self.gig.editCountry = country.name
                    }
                }
            )
            navigationController?.pushViewController(countrySelect, animated: true)
        } else if indexPath.section == SECTION_META && indexPath.row == ROW_CITY {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let citySelect = ListSelectionController.create(withFilter: "Enter city", initialFilter: gig.editCity, enableCustom: true,
                filterCallback: { filterText in
                    return dataContext().cityList(filterText)
                },
                displayCallback: { item in
                    return (item as? City)!.name
                },
                selectCallback: { custom, item in
                    if let city = item as? City {
                        self.gig.editCity = city.name
                    } else if custom {
                        self.gig.editCity = item as! String
                    }
                }
            )
            
            navigationController?.pushViewController(citySelect, animated: true)
        } else if indexPath.section == SECTION_META && indexPath.row == ROW_VENUE {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let venueSelect = ListSelectionController.create(withFilter: "Enter venue", initialFilter: gig.editVenue, enableCustom: true,
                filterCallback: { filterText in
                    return dataContext().venueList(filterText)
                },
                displayCallback: { item in
                    return (item as? Venue)!.name
                },
                selectCallback: { custom, item in
                    if let venue = item as? Venue {
                        self.gig.editVenue = venue.name
                    } else if custom {
                        self.gig.editVenue = item as! String
                    }
                }
            )
            
            navigationController?.pushViewController(venueSelect, animated: true)
        }
        
        if doReload {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func setUIFields() {
        startDatePicker.date = gig.startDate
        startTimePicker.date = gig.startDate
        updateStartLabels()
        
        durationPicker.timeInterval = DateUtils.diff(gig.endDate, dateBegin: gig.startDate)
        updateEndLabels()
        
        textCountry.text = gig.editCountry
        textCity.text    = gig.editCity
        textVenue.text   = gig.editVenue
        textStage.text   = gig.stage
        
        ratingControl.rating = gig.rating.floatValue / 10
        
        switchSupportAct.on = gig.supportAct
        
        validateForm()
    }
    
    private func updateStartLabels() {
        dateLabels[START_DATE].text = DateUtils.toDateStringMedium(gig.startDate)
        dateLabels[START_TIME].text = DateUtils.toTimeStringShort(gig.startDate)
    }
    
    private func updateEndLabels() {
        dateLabels[DURATION].text = durationPicker.formattedString
    }
        
    private func togglePicker(picker : Int) {
        
        for var idx = 0; idx < datePickerEditing.count; ++idx {
            datePickerEditing[idx]  = (picker == idx) ? !datePickerEditing[idx] : false
            
            datePickers[idx].hidden     = !datePickerEditing[idx]
            dateLabels[idx].textColor   = datePickerEditing[idx] ? UIColor.redColor() : UIColor.blackColor()
        }
        
    }
    
    private func validateForm() {
        var isValid : Bool = true
        
        // country moet ingevuld zijn
        if gig.editCountry.isEmpty {
            isValid = false
        }
        
        
        if let delegate = delegate {
            delegate.enableSave(isValid)
        }
    }
}
