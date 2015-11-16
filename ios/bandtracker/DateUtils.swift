//
//  DateUtils.swift
//  bandtracker
//
//  Created by Johan Smet on 07/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation


class DateUtils {
   
    static func join(date : NSDate, time : NSDate) -> NSDate {
        let cal = NSCalendar.currentCalendar()
        
        let dateComponents = cal.components([.Year, .Month, .Day], fromDate: date)
        let timeComponents = cal.components([.Hour, .Minute, .Second], fromDate: time)
       
        dateComponents.second = timeComponents.second
        dateComponents.minute = timeComponents.minute
        dateComponents.hour   = timeComponents.hour
        
        return cal.dateFromComponents(dateComponents)!
    }
    
    static func currentTimeRoundMinutes(interval : Int) -> NSDate {
        
        let cal = NSCalendar.currentCalendar()
        
        let dateComponents = cal.components([.Year, .Month, .Day], fromDate: NSDate())
        let timeComponents = cal.components([.Hour, .Minute], fromDate: NSDate())
        
        dateComponents.hour   = timeComponents.hour
        dateComponents.minute = (timeComponents.minute / interval) * interval
        
        return cal.dateFromComponents(dateComponents)!
    }
    
    static func currentYear() -> Int {
        let cal = NSCalendar.currentCalendar()
        return cal.component(.Year, fromDate: NSDate())
    }
    
    static func stripTime(date : NSDate) -> NSDate  {
        let cal = NSCalendar.currentCalendar()
        let dateComponents = cal.components([.Year, .Month, .Day], fromDate: date)
        return cal.dateFromComponents(dateComponents)!
    }
    
    static func add(date : NSDate, interval : NSTimeInterval) -> NSDate {
        return date.dateByAddingTimeInterval(interval)
    }
    
    static func diff(dateEnd : NSDate, dateBegin : NSDate) -> NSTimeInterval {
        return dateEnd.timeIntervalSinceDate(dateBegin)
    }
    
    static func toDateStringMedium(date : NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        
        return dateFormatter.stringFromDate(date)
    }
    
    static func toTimeStringShort(date : NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(date)
    }
    
    static func format(date : NSDate, format : String) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
       
        return dateFormatter.stringFromDate(date)
    }
    
    static func format(interval : NSTimeInterval, format : String) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        
        let date = NSDate(timeIntervalSinceReferenceDate: interval)
        return dateFormatter.stringFromDate(date)
    }
    
    static func dateFromStringISO(dateString : String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        return dateFormatter.dateFromString(dateString)
    }
    
}

