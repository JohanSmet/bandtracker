//
//  TimeIntervalPicker.swift
//  bandtracker
//
//  Created by Johan Smet on 20/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class TimeIntervalPicker :  UIControl,
                                   UIPickerViewDataSource,
                                   UIPickerViewDelegate {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // properties
    //
    
    open var dayValue : Int {
        get {
            return picker.selectedRow(inComponent: componentDays)
        }
        
        set (day) {
            picker.selectRow(day, inComponent: componentDays, animated: false)
        }
    }
    
    open var hourValue : Int {
        get {
            return picker.selectedRow(inComponent: componentHours) % componentRowCount[componentHours]
        }
        
        set (hour) {
            picker.selectRow((rowInfiniteCount / 2) + hour, inComponent: componentHours, animated: false)
        }
    }
    
    open var minuteValue : Int {
        get {
            return (picker.selectedRow(inComponent: componentMinutes) % componentRowCount[componentMinutes]) * minuteInterval
        }
        set (minute) {
            let row = minute / minuteInterval
            picker.selectRow((rowInfiniteCount / 2) + row, inComponent: componentMinutes, animated: false)
        }
    }
    
    open var timeInterval : TimeInterval {
        get {
            let daySec    = dayValue * SECONDS_IN_DAY
            let hourSec   = hourValue * SECONDS_IN_HOUR
            let minuteSec = minuteValue * SECONDS_IN_MINUTE
            
            return TimeInterval(daySec + hourSec + minuteSec)
        }
        
        set (interval) {
            let days    = Int(interval) / SECONDS_IN_DAY
            let hours   = (Int(interval) - (days * SECONDS_IN_DAY)) / SECONDS_IN_HOUR
            let minutes = (Int(interval) - (days * SECONDS_IN_DAY) - (hours * SECONDS_IN_HOUR)) / SECONDS_IN_MINUTE
            
            dayValue = days
            hourValue = hours
            minuteValue = minutes
        }
    }
    
    open var formattedString : String {
        get {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            
            return formatter.string(from: timeInterval)!
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // private variables
    //
    
    fileprivate var picker : UIPickerView!
    
    fileprivate let componentRowCount : [Int]   = [10, 24, 12]
    fileprivate let rowInfiniteCount  : Int     = 1200
    fileprivate let componentWidth    : CGFloat = 50
    fileprivate let minuteInterval    : Int     = 60 / 12
    
    fileprivate let componentDays     : Int     = 0
    fileprivate let componentHours    : Int     = 1
    fileprivate let componentMinutes  : Int     = 2
    
    fileprivate let SECONDS_IN_MINUTE : Int = 60
    fileprivate let SECONDS_IN_HOUR   : Int = 60 * 60
    fileprivate let SECONDS_IN_DAY    : Int = 60 * 60 * 24
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createPicker()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createPicker()
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UIPickerViewDataSource
    //
    
    @objc open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (component) {
            case componentDays    : return componentRowCount[component]
            case componentHours   : return rowInfiniteCount          // simulate wrapping
            case componentMinutes : return rowInfiniteCount          // simulate wrapping
            default               : return 0
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UIPickerViewDelegate
    //
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        switch (component) {
            case componentDays    : return "\(row)"
            case componentHours   : return "\(row % componentRowCount[component])"
            case componentMinutes : return String(format:"%02d", (row % componentRowCount[component]) * 5)
            default :               return ""
        }
    }
    
    open func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return componentWidth
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // reset to near center position to simulate infinite scrolling
        if component == componentHours || component == componentMinutes {
            pickerView.selectRow(row % componentRowCount[component] + (rowInfiniteCount / 2), inComponent: component, animated: false)
        }
        
        sendActions(for: .valueChanged)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    fileprivate func createPicker() {
        
        func addPickerConstraint(_ picker : UIView, attribute : NSLayoutAttribute, relation : NSLayoutRelation) {
            addConstraint(NSLayoutConstraint(
                            item: picker,
                            attribute: attribute,
                            relatedBy: relation,
                            toItem: self,
                            attribute: attribute,
                            multiplier: 1.0,
                            constant: 0))
            
        }
        
        picker = UIPickerView()
        picker.delegate     = self
        picker.dataSource   = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        addSubview(picker)
        
        // set constraints to fill entire container
        addPickerConstraint(picker, attribute: NSLayoutAttribute.width, relation: NSLayoutRelation.equal)
        addPickerConstraint(picker, attribute: NSLayoutAttribute.height, relation: NSLayoutRelation.equal)
        addPickerConstraint(picker, attribute: NSLayoutAttribute.top, relation: NSLayoutRelation.equal)
        addPickerConstraint(picker, attribute: NSLayoutAttribute.leading, relation: NSLayoutRelation.equal)
        
        // center components to simulate infinite scrolling
        picker.selectRow(rowInfiniteCount / 2, inComponent: componentHours, animated: false)
        picker.selectRow(rowInfiniteCount / 2, inComponent: componentMinutes, animated: false)
    }
    
    
}
