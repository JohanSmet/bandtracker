//
//  DateUtils.swift
//  bandtracker
//
//  Created by Johan Smet on 07/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation


class DateUtils {
   
    static func join(_ date : Date, time : Date) -> Date {
        let cal = Calendar.current
        
        var dateComponents = (cal as NSCalendar).components([.year, .month, .day], from: date)
        let timeComponents = (cal as NSCalendar).components([.hour, .minute, .second], from: time)
       
        dateComponents.second = timeComponents.second
        dateComponents.minute = timeComponents.minute
        dateComponents.hour   = timeComponents.hour
        
        return cal.date(from: dateComponents)!
    }
    
    static func currentTimeRoundMinutes(_ interval : Int) -> Date {
        
        let cal = Calendar.current
        
        var dateComponents = (cal as NSCalendar).components([.year, .month, .day], from: Date())
        let timeComponents = (cal as NSCalendar).components([.hour, .minute], from: Date())
        
        dateComponents.hour   = timeComponents.hour
        dateComponents.minute = (timeComponents.minute! / interval) * interval
        
        return cal.date(from: dateComponents)!
    }
    
    static func currentYear() -> Int {
        let cal = Calendar.current
        return (cal as NSCalendar).component(.year, from: Date())
    }
    
    static func stripTime(_ date : Date) -> Date  {
        let cal = Calendar.current
        let dateComponents = (cal as NSCalendar).components([.year, .month, .day], from: date)
        return cal.date(from: dateComponents)!
    }
    
    static func add(_ date : Date, interval : TimeInterval) -> Date {
        return date.addingTimeInterval(interval)
    }
    
    static func diff(_ dateEnd : Date, dateBegin : Date) -> TimeInterval {
        return dateEnd.timeIntervalSince(dateBegin)
    }
    
    static func toDateStringMedium(_ date : Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: date)
    }
    
    static func toTimeStringShort(_ date : Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: date)
    }
    
    static func format(_ date : Date, format : String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
       
        return dateFormatter.string(from: date)
    }
    
    static func format(_ interval : TimeInterval, format : String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return dateFormatter.string(from: date)
    }
    
    static func dateFromStringISO(_ dateString : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        return dateFormatter.date(from: dateString)
    }
    
}

