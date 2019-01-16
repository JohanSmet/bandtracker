//
//  GigDetailsController.swift
//  bandtracker
//
//  Created by Johan Smet on 30/09/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GigDetailsController :    UITableViewController,
                                UITextFieldDelegate,
                                RatingControlDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    let SECTION_DATES = 0
    let SECTION_META  = 1
    let SECTION_LINKS = 3
    
    let ROW_COUNTRY   = 0
    let ROW_CITY      = 1
    let ROW_VENUE     = 2
    let ROW_SETLIST   = 0
    let ROW_YOUTUBE   = 1
    
    let START_DATE = 0
    let START_TIME = 1
    let DURATION   = 2
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var scratchContext  : NSManagedObjectContext = coreDataStackManager().childObjectContext()
    var gig             : Gig!
    
    var datePickerRows      : [Int]  = [1, 3, 5]
    var datePickerEditing   : [Bool] = [false, false, false]
    var datePickerHeight    : CGFloat = 0
    
    var editable            : Bool = false
    
    fileprivate var keyboardFix     : KeyboardFix?
    
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
    
    @IBOutlet weak var countryImage: UIImageView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // class functions
    //
    
    class func createNewGig(_ band : Band) -> GigDetailsController {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewController(withIdentifier: "GigDetailsController") as! GigDetailsController
        newVC.editable  = true
        newVC.gig       = Gig(band: newVC.scratchContext.object(with: band.objectID) as! Band, context: newVC.scratchContext)
        
        return newVC
    }
    
    class func createNewGig(_ band : Band, tourDate : BandTrackerClient.TourDate) -> GigDetailsController {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewController(withIdentifier: "GigDetailsController") as! GigDetailsController
        newVC.editable  = true
        newVC.gig       = dataContext().gigFromTourDate(newVC.scratchContext.object(with: band.objectID) as! Band, tourDate: tourDate, context: newVC.scratchContext)
        
        return newVC
    }
    
    class func displayGig(_ gig : Gig) -> GigDetailsController {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewController(withIdentifier: "GigDetailsController") as! GigDetailsController
        newVC.editable  = false
        newVC.gig  = newVC.scratchContext.object(with: gig.objectID) as? Gig
        newVC.gig = gig
        
        return newVC
    }
    
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
        
        textStage.isEnabled       = editable
        textComments.isEnabled    = editable
        ratingControl.isEnabled   = editable
        
        // initialize gig-record
        gig.prepareForEdit()
        
        // configure navigation controller
        createNavigationButtons()
        
        keyboardFix = KeyboardFix(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUIFields()
        
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
    // actions
    //
    
    @objc func saveGig() {
        if let gig = gig {
            gig.supportAct = switchSupportAct.isOn
            gig.processEdit()
            saveContext()
            
            gig.band.totalRating = NSNumber(value: dataContext().totalRatingOfGigs(gig.band))
            gig.band.avgRating   = NSNumber(value: gig.band.rating())
            saveContext()

            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func editGig() {
        setEditable(true)
        createNavigationButtons()
    }
    
    @IBAction func pickStartChanged(_ sender: UIDatePicker) {
        gig.startDate = DateUtils.join(startDatePicker.date, time: startTimePicker.date)
        updateStartLabels()
        validateForm()
    }
    
    @IBAction func pickDurationChanged(_ sender: TimeIntervalPicker) {
        gig.endDate = DateUtils.add(gig.startDate, interval: durationPicker.timeInterval)
        updateEndLabels()
        validateForm()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate
    //
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableView.scrollRectToVisible(textField.convert(textField.frame, to: tableView), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
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
    
    func ratingDidChange(_ ratingControl: RatingControl, newRating: Float, oldRating: Float) {
        gig.rating = NSNumber(value: Int(newRating * 10))
        validateForm()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == SECTION_DATES {
            if let index = datePickerRows.index(of: indexPath.row) {
                return self.datePickerEditing[index] ? datePickerHeight : 0
            }
        } else if indexPath.section == SECTION_LINKS && editable {
            return 0
        }
        
        return self.tableView.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var doReload = false
        
        if !editable && indexPath.section != SECTION_LINKS {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        if indexPath.section == SECTION_DATES {
            if let index = datePickerRows.index(of: indexPath.row + 1) {
                togglePicker(index)
                tableView.deselectRow(at: indexPath, animated: true)
                doReload = true
            }
        }
        else if indexPath.section == SECTION_META && indexPath.row == ROW_COUNTRY {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let countrySelect = ListSelectionController.create(CountrySelectionDelegate(initialFilter: gig.editCountry) { name in
                self.gig.editCountry = name
                self.gig.country     = dataContext().countryByName(name, context: self.gig.managedObjectContext!)
                })
            
            navigationController?.pushViewController(countrySelect, animated: true)
        } else if indexPath.section == SECTION_META && indexPath.row == ROW_CITY {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let citySelect = ListSelectionController.create(CitySelectionDelegate(initialFilter: gig.editCity, countryCode: gig.country.code) { name in
                self.gig.editCity = name
                })
            
            navigationController?.pushViewController(citySelect, animated: true)
        } else if indexPath.section == SECTION_META && indexPath.row == ROW_VENUE {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let venueSelect = ListSelectionController.create(VenueSelectionDelegate(initialFilter: gig.editVenue, countryCode: gig.country.code, city: gig.editCity) { name in
                self.gig.editVenue = name
                })
            
            navigationController?.pushViewController(venueSelect, animated: true)
        } else if indexPath.section == SECTION_LINKS && indexPath.row == ROW_SETLIST {
            tableView.deselectRow(at: indexPath, animated: true)
         
            let vc = GigDetailsSetlistController.create(gig)
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == SECTION_LINKS && indexPath.row == ROW_YOUTUBE {
            tableView.deselectRow(at: indexPath, animated: true)
         
            let vc = GigDetailsYoutubeController.create(gig)
            navigationController?.pushViewController(vc, animated: true)
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
    
    func createNavigationButtons() {
        if editable {
            let buttonSave = UIBarButtonItem(title: NSLocalizedString("conSave", comment: "Save"), style: .plain, target: self, action: #selector(GigDetailsController.saveGig))
            self.navigationItem.setRightBarButtonItems([buttonSave], animated: false)
            validateForm()
        } else {
            let buttonEdit = UIBarButtonItem(title: NSLocalizedString("conEdit", comment: "Edit"), style: .plain, target: self, action: #selector(GigDetailsController.editGig))
            self.navigationItem.setRightBarButtonItems([buttonEdit], animated: false)
        }
    }
    
    fileprivate func setUIFields() {
        startDatePicker.date = gig.startDate as Date
        startTimePicker.date = gig.startDate as Date
        updateStartLabels()
        
        durationPicker.timeInterval = DateUtils.diff(gig.endDate, dateBegin: gig.startDate)
        updateEndLabels()
        
        textCountry.text = gig.editCountry
        textCity.text    = gig.editCity
        textVenue.text   = gig.editVenue
        textStage.text   = gig.stage
        
        ratingControl.rating = gig.rating.floatValue / 10
        
        switchSupportAct.isOn = gig.supportAct
        
        if let flag = gig.country.flag {
            countryImage.image = UIImage(data: flag as Data)
        }
        
        validateForm()
    }
    
    fileprivate func updateStartLabels() {
        dateLabels[START_DATE].text = DateUtils.toDateStringMedium(gig.startDate)
        dateLabels[START_TIME].text = DateUtils.toTimeStringShort(gig.startDate)
    }
    
    fileprivate func updateEndLabels() {
        if durationPicker.timeInterval > 0 {
            dateLabels[DURATION].text = durationPicker.formattedString
        } else {
            dateLabels[DURATION].text = NSLocalizedString("conIntervalNotSet", comment: "not set")
        }
    }
    
    fileprivate func togglePicker(_ picker : Int) {
        
        for idx in 0 ..< datePickerEditing.count {
            datePickerEditing[idx]  = (picker == idx) ? !datePickerEditing[idx] : false
            
            datePickers[idx].isHidden     = !datePickerEditing[idx]
            dateLabels[idx].textColor   = datePickerEditing[idx] ? UIColor.red : UIColor.black
        }
        
    }
    
    fileprivate func validateForm() {
         var isValid : Bool = true
        
        // country moet ingevuld zijn
        if gig.editCountry.isEmpty {
            isValid = false
        }
     
        navigationItem.rightBarButtonItem?.isEnabled = isValid
    }
    
    fileprivate func setEditable(_ editable : Bool) {
        self.editable = editable
        textStage.isEnabled       = editable
        textComments.isEnabled    = editable
        ratingControl.isEnabled   = editable
        self.tableView.reloadData()
    }
    
    fileprivate func saveContext() {
        let _ = coreDataStackManager().saveChildContext(scratchContext)
        let _ = coreDataStackManager().saveContext()
    }
    
}
