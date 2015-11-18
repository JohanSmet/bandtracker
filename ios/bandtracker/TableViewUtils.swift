//
//  TableViewUtils.swift
//  bandtracker
//
//  Created by Johan Smet on 18/11/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class TableViewUtils {
    
    class func messageEmptyTable(tableView: UITableView, isEmpty : Bool, message : String)  {
        
        if isEmpty {
            
            let msgLabel = UILabel(frame: CGRectMake(0, 20, tableView.bounds.width, 20))
            
            msgLabel.text = message
            msgLabel.textColor = UIColor.grayColor()
            msgLabel.numberOfLines = 0
            msgLabel.textAlignment = .Center
            msgLabel.font = UIFont(name: "Lato", size: 20)
            
            let msgView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, tableView.bounds.height))
            msgView.addSubview(msgLabel)
            
            
            tableView.backgroundView = msgView
            tableView.separatorStyle = .None;
            
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .SingleLine
        }
        
    }
    
}