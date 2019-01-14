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
    
    class func messageEmptyTable(_ tableView: UITableView, isEmpty : Bool, message : String)  {
        
        if isEmpty {
            
            let msgLabel = UILabel(frame: CGRect(x: 16, y: 20, width: tableView.bounds.width - 32, height: 20))
            
            msgLabel.text = message
            msgLabel.textColor = UIColor.gray
            msgLabel.numberOfLines = 0
            msgLabel.textAlignment = .center
            msgLabel.font = UIFont(name: "Lato", size: 20)
            msgLabel.lineBreakMode = .byWordWrapping
            msgLabel.sizeToFit()
            msgLabel.frame.origin.x = (tableView.bounds.width - msgLabel.bounds.width) / 2
            
            let msgView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
            msgView.addSubview(msgLabel)
            
            
            tableView.backgroundView = msgView
            tableView.separatorStyle = .none;
            
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        
    }
    
}
