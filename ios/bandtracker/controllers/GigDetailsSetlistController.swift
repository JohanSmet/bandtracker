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
    
    fileprivate var gig         : Gig!
    
    fileprivate var set : [SetlistFmClient.SetPart] = []
    fileprivate var error : String = ""
    fileprivate var urlString : String?
    
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
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // static interface
    //
    
    class func create(_ gig : Gig) -> GigDetailsSetlistController {
        
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewController(withIdentifier: "GigDetailsSetlistController") as! GigDetailsSetlistController
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
        tableView.isHidden = false
        
        // init website link
        let tapRecognizer = UITapGestureRecognizer(target: self, action : #selector(GigDetailsSetlistController.visitSetlistFm))
        tapRecognizer.numberOfTapsRequired = 1
        labelWebsite.addGestureRecognizer(tapRecognizer)
        
        // load the setlist
        setlistFmClient().searchSetlist(gig) { setlist, setlistUrl, error in
            
            DispatchQueue.main.async {
                
                if let setlist = setlist {
                    self.set = setlist
                } else {
                    self.set = []
                }
                
                if let error = error {
                    self.error = error
                } else {
                    self.error = ""
                }
                
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.tableView.reloadData()
                
                if let setlistUrl = setlistUrl {
                    self.urlString = setlistUrl
                }
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func visitSetlistFm() {
        if let url = URL(string: self.urlString!) {
            UIApplication.shared.openURL(url)
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if error.isEmpty {
            TableViewUtils.messageEmptyTable(tableView, isEmpty: set.isEmpty, message: NSLocalizedString("conNoSetlist", comment: "No set list found for this gig."))
        } else {
            TableViewUtils.messageEmptyTable(tableView, isEmpty: true, message: error)
        }
        
        return set.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return set[section].songs.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return set[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetListCell", for: indexPath)
        let song = set[indexPath.section].songs[indexPath.row]
        cell.textLabel!.text = "\(indexPath.row + 1). \(song)"
        return cell
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let song = set[indexPath.section].songs[indexPath.row]
        let vc = GigDetailsYoutubeController.create(gig, song: song)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    fileprivate func setHeaderFields() {
        
        locationLabel.text =  gig.formatLocation()
        dateLabel.text = DateUtils.toDateStringMedium(gig.startDate)
        
        UrlFetcher.loadImageFromUrl(gig.band.fanartLogoUrl ?? "") { image in
            self.bandLogo.image = image
        }
    }
}
