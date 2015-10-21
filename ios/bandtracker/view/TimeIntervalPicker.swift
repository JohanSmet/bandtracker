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
public class TimeIntervalPicker :  UIControl,
                                   UIPickerViewDataSource,
                                   UIPickerViewDelegate {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // properties
    //
    
    public var dayValue : Int {
        get {
            return picker.selectedRowInComponent(componentDays)
        }
        
        set (day) {
            picker.selectRow(day, inComponent: componentDays, animated: false)
        }
    }
    
    public var hourValue : Int {
        get {
            return picker.selectedRowInComponent(componentHours) % componentRowCount[componentHours]
        }
        
        set (hour) {
            picker.selectRow((rowInfiniteCount / 2) + hour, inComponent: componentHours, animated: false)
        }
    }
    
    public var minuteValue : Int {
        get {
            return (picker.selectedRowInComponent(componentMinutes) % componentRowCount[componentMinutes]) * minuteInterval
        }
        set (minute) {
            let row = minute / minuteInterval
            picker.selectRow((rowInfiniteCount / 2) + row, inComponent: componentMinutes, animated: false)
        }
    }
    
    public var timeInterval : NSTimeInterval {
        get {
            let daySec    = dayValue * SECONDS_IN_DAY
            let hourSec   = hourValue * SECONDS_IN_HOUR
            let minuteSec = minuteValue * SECONDS_IN_MINUTE
            
            return NSTimeInterval(daySec + hourSec + minuteSec)
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
    
    public var formattedString : String {
        get {
            let formatter = NSDateComponentsFormatter()
            formatter.unitsStyle = .Short
            
            return formatter.stringFromTimeInterval(timeInterval)!
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // private variables
    //
    
    private var picker : UIPickerView!
    
    private let componentRowCount : [Int]   = [10, 24, 12]
    private let rowInfiniteCount  : Int     = 1200
    private let componentWidth    : CGFloat = 50
    private let minuteInterval    : Int     = 60 / 12
    
    private let componentDays     : Int     = 0
    private let componentHours    : Int     = 1
    private let componentMinutes  : Int     = 2
    
    private let SECONDS_IN_MINUTE : Int = 60
    private let SECONDS_IN_HOUR   : Int = 60 * 60
    private let SECONDS_IN_DAY    : Int = 60 * 60 * 24
    
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
    
    @objc public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        switch (component) {
            case componentDays    : return "\(row)"
            case componentHours   : return "\(row % componentRowCount[component])"
            case componentMinutes : return String(format:"%02d", (row % componentRowCount[component]) * 5)
            default :               return ""
        }
    }
    
    public func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return componentWidth
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // reset to near center position to simulate infinite scrolling
        if component == componentHours || component == componentMinutes {
            pickerView.selectRow(row % componentRowCount[component] + (rowInfiniteCount / 2), inComponent: component, animated: false)
        }
        
        sendActionsForControlEvents(.ValueChanged)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func createPicker() {
        
        func addPickerConstraint(picker : UIView, attribute : NSLayoutAttribute, relation : NSLayoutRelation) {
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
        addPickerConstraint(picker, attribute: NSLayoutAttribute.Width, relation: NSLayoutRelation.Equal)
        addPickerConstraint(picker, attribute: NSLayoutAttribute.Height, relation: NSLayoutRelation.Equal)
        addPickerConstraint(picker, attribute: NSLayoutAttribute.Top, relation: NSLayoutRelation.Equal)
        addPickerConstraint(picker, attribute: NSLayoutAttribute.Leading, relation: NSLayoutRelation.Equal)
        
        // center components to simulate infinite scrolling
        picker.selectRow(rowInfiniteCount / 2, inComponent: componentHours, animated: false)
        picker.selectRow(rowInfiniteCount / 2, inComponent: componentMinutes, animated: false)
    }
    
    
}