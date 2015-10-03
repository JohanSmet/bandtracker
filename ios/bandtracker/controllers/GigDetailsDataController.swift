//
//  GigDetailsDataController.swift
//  bandtracker
//
//  Created by Johan Smet on 30/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class GigDetailsDataController : UITableViewController {
    
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
    
    var editingStartDate : Bool = false
    var editingEndDate : Bool = false
    var datePickerHeight : CGFloat = 0
    
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
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerHeight = pickStart.bounds.height
        
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    
}
