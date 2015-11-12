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
                                    UITableViewDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private var gig         : Gig!
    
    private var set : [SetlistFmClient.SetPart] = []
    private var urlString : String?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelWebsite: UILabel!
    
    // header
    @IBOutlet weak var bandLogo: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorMsg: UILabel!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // static interface
    //
    
    class func create(gig : Gig) -> GigDetailsSetlistController {
        
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewControllerWithIdentifier("GigDetailsSetlistController") as! GigDetailsSetlistController
        newVC.gig = gig
        
        return newVC
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init header
        setHeaderFields()
        
        // init tableview
        tableView.dataSource = self
        tableView.delegate   = self
        
        // init website link
        let tapRecognizer = UITapGestureRecognizer(target: self, action : "visitSetlistFm")
        tapRecognizer.numberOfTapsRequired = 1
        labelWebsite.addGestureRecognizer(tapRecognizer)
        
        // load the setlist
        setlistFmClient().searchSetlist(gig) { setlist, setlistUrl, error in
            
            if setlist != nil && setlist!.count > 0 {
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.set = setlist!
                    
                    self.tableView.hidden = false
                    self.tableView.reloadData()
                    
                    if let setlistUrl = setlistUrl {
                        self.urlString = setlistUrl
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    
                    if let error = error {
                        self.errorMsg.text = error
                    }
                    self.errorView.hidden = false
                    self.footerView.hidden = true
                }
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
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let song = set[indexPath.section].songs[indexPath.row]
        let vc = GigDetailsYoutubeController.create(gig, song: song)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func setHeaderFields() {
        
        locationLabel.text =  gig.formatLocation()
        dateLabel.text = DateUtils.toDateStringMedium(gig.startDate)
        
        UrlFetcher.loadImageFromUrl(gig.band.fanartLogoUrl ?? "") { image in
            self.bandLogo.image = image
        }
    }
}