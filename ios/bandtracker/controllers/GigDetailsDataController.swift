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
   
    static let SECTION_START_DATE = 0
    static let ROW_START_DATE = 1
    static let SECTION_END_DATE = 0
    static let ROW_END_DATE = 3
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var gig : Gig!
    var editingStartDate : Bool = false
    var editingEndDate : Bool = false
    var datePickerHeight : CGFloat = 0
    
    var dateFormatter : NSDateFormatter!
    var timeFormatter : NSDateFormatter!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelStartTime: UILabel!
    @IBOutlet weak var pickStart: UIDatePicker!
    
    @IBOutlet weak var labelEndDate: UILabel!
    @IBOutlet weak var labelEndTime: UILabel!
    @IBOutlet weak var pickEnd: UIDatePicker!
    
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
        datePickerHeight = pickStart.bounds.height
        
        // prepare formatters for date and time
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        
        timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .NoStyle
        timeFormatter.timeStyle = .MediumStyle
        
        // set delegates
        textCountry.delegate = self
        textCity.delegate = self
        textVenue.delegate = self
        textStage.delegate = self
        textComments.delegate = self
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
        gig.startDate = sender.date
        updateStartLabels()
    }
    
    @IBAction func pickEndChanged(sender: UIDatePicker) {
        gig.endDate = sender.date
        updateEndLabels()
    }
    
    @IBAction func cityChanged(sender: UITextField) {
        gig.editCity = sender.text!
    }
    
    @IBAction func venueChanged(sender: UITextField) {
        gig.editVenue = sender.text!
    }
    
    @IBAction func stageChanged(sender: UITextField) {
        gig.stage = sender.text!
    }
    
    @IBAction func commensChanged(sender: UITextField) {
        gig.comments = sender.text!
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
        
        if indexPath.section == GigDetailsDataController.SECTION_START_DATE && indexPath.row == GigDetailsDataController.ROW_START_DATE {
            return (self.editingStartDate) ? datePickerHeight : 0
        } else if indexPath.section == GigDetailsDataController.SECTION_END_DATE && indexPath.row == GigDetailsDataController.ROW_END_DATE {
            return (self.editingEndDate) ? datePickerHeight : 0
        }
        
        return self.tableView.rowHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var doReload = false
        
        if indexPath.section == GigDetailsDataController.SECTION_START_DATE && indexPath.row == GigDetailsDataController.ROW_START_DATE - 1 {
            editingStartDate = !editingStartDate
            editingEndDate = false
            doReload = true
        } else if indexPath.section == GigDetailsDataController.SECTION_END_DATE && indexPath.row == GigDetailsDataController.ROW_END_DATE - 1 {
            editingStartDate = false
            editingEndDate = !editingEndDate
            doReload = true
        }
        
        if doReload {
            pickStart.hidden = !editingStartDate
            pickEnd.hidden = !editingEndDate
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func setUIFields() {
        pickStart.date = gig.startDate
        updateStartLabels()
        
        pickEnd.date = gig.endDate
        updateEndLabels()
        
        textCountry.text = gig.editCountry
        textCity.text    = gig.editCity
        textVenue.text   = gig.editVenue
        textStage.text   = gig.stage
        
        switchSupportAct.on = gig.supportAct
    }
    
    private func updateStartLabels() {
        labelStartDate.text = dateFormatter.stringFromDate(gig.startDate)
        labelStartTime.text = timeFormatter.stringFromDate(gig.startDate)
    }
    
    private func updateEndLabels() {
        labelEndDate.text = dateFormatter.stringFromDate(gig.endDate)
        labelEndTime.text = timeFormatter.stringFromDate(gig.endDate)
    }
}
