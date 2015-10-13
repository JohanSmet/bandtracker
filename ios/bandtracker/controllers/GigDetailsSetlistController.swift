//
//  GigDetailsSetlistController.swift
//  bandtracker
//
//  Created by Johan Smet on 01/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class GigDetailsSetlistController : UIViewController ,
                                    UITableViewDataSource,
                                    GigDetailsSubView {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var gig : Gig!
    var set : [SetlistFmClient.SetPart] = []
    var urlString : String?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelWebsite: UILabel!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // GigDetailsSubView
    //
    
    func setEditableControls(edit: Bool) {
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init tableview
        tableView.dataSource = self
        
        // init website link
        let tapRecognizer = UITapGestureRecognizer(target: self, action : "visitSetlistFm")
        tapRecognizer.numberOfTapsRequired = 1
        labelWebsite.addGestureRecognizer(tapRecognizer)
        
        // load the setlist
        setlistFmClient().searchSetlist(gig) { setlist, setlistUrl, error in
            // XXX display error
            
            if let setlist = setlist {
                self.set = setlist
                self.tableView.reloadData()
            }
            
            if let setlistUrl = setlistUrl {
                self.urlString = setlistUrl
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func visitSetlistFm() {
        if let url = NSURL(string: self.urlString!) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return set.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return set[section].songs.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return set[section].name
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("SetListCell", forIndexPath: indexPath)
        let song = set[indexPath.section].songs[indexPath.row]
        cell.textLabel!.text = "\(indexPath.row + 1). \(song)"
        return cell
        
    }
    
}