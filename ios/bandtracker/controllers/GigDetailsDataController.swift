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
                                 GigDetailsSubView {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
   
    let SECTION_DATES = 0
    let START_DATE = 0
    let START_TIME = 1
    let END_DATE   = 2
    let END_TIME   = 3
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var gig : Gig!
    
    var datePickerRows      : [Int]  = [1, 3, 5, 7]
    var datePickerEditing   : [Bool] = [false, false, false, false]
    var datePickerHeight    : CGFloat = 0
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet var datePickers : [UIDatePicker]!
    @IBOutlet var dateLabels  : [UILabel]!
    
    @IBOutlet weak var textCountry: UITextField!
    @IBOutlet weak var textCity: UITextField!
    @IBOutlet weak var textVenue: UITextField!
    @IBOutlet weak var textStage: UITextField!
    
    @IBOutlet weak var switchSupportAct: UISwitch!
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIFields()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func pickStartChanged(sender: UIDatePicker) {
        gig.startDate = DateUtils.join(datePickers[START_DATE].date, time: datePickers[START_TIME].date)
        updateStartLabels()
    }
    
    @IBAction func pickEndChanged(sender: UIDatePicker) {
        gig.endDate = DateUtils.join(datePickers[END_DATE].date, time: datePickers[END_TIME].date)
        updateEndLabels()
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
        
        if indexPath.section == SECTION_DATES {
            
            if let index = datePickerRows.indexOf(indexPath.row + 1) {
                togglePicker(index)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                doReload = true
            }
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
        datePickers[START_DATE].date = gig.startDate
        datePickers[START_TIME].date = gig.startDate
        updateStartLabels()
        
        datePickers[END_DATE].date = gig.endDate
        datePickers[END_TIME].date = gig.endDate
        updateEndLabels()
        
        textCountry.text = gig.editCountry
        textCity.text    = gig.editCity
        textVenue.text   = gig.editVenue
        textStage.text   = gig.stage
        
        switchSupportAct.on = gig.supportAct
    }
    
    private func updateStartLabels() {
        dateLabels[START_DATE].text = DateUtils.toDateStringMedium(gig.startDate)
        dateLabels[START_TIME].text = DateUtils.toTimeStringShort(gig.startDate)
    }
    
    private func updateEndLabels() {
        dateLabels[END_DATE].text = DateUtils.toDateStringMedium(gig.endDate)
        dateLabels[END_TIME].text = DateUtils.toTimeStringShort(gig.endDate)
    }
        
    private func togglePicker(picker : Int) {
        
        for var idx = 0; idx < datePickerEditing.count; ++idx {
            datePickerEditing[idx]  = (picker == idx) ? !datePickerEditing[idx] : false
            
            datePickers[idx].hidden     = !datePickerEditing[idx]
            dateLabels[idx].textColor   = datePickerEditing[idx] ? UIColor.redColor() : UIColor.blackColor()
        }
        
    }
}
