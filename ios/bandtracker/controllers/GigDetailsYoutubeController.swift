//
//  GigDetailsYoutubeController.swift
//  bandtracker
//
//  Created by Johan Smet on 03/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class GigDetailsYoutubeController : UIViewController,
                                    UITableViewDataSource,
                                    UITableViewDelegate {

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private var gig         : Gig!
    private var song        : String!
    
    private var videos      : [YoutubeDataClient.Video] = []
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bandLogo: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var searchLabel: UILabel!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorMsg: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // static interface
    //
    
    class func create(gig : Gig, song : String? = nil) -> GigDetailsYoutubeController {
        
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewControllerWithIdentifier("GigDetailsYoutubeController") as! GigDetailsYoutubeController
        newVC.gig = gig
        newVC.song = song
        
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
        
        // init table view
        tableView.dataSource = self
        tableView.delegate   = self
        
        // load the videos
        searchForVideos()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("YoutubeCell", forIndexPath: indexPath) as! YoutubeTableViewCell
        let video = self.videos[indexPath.row]
        
        cell.videoTitle!.text = video.title
        cell.videoPlayer.loadVideoID(video.id)
        
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    func searchForVideos() {
        youtubeDataClient().searchVideosForGig(gig, song: song, maxResults: 10) { videos, error in
            if videos != nil && videos!.count > 0 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.videos = videos!
                    
                    self.activityIndicator.stopAnimating()
                    self.tableView.hidden = false
                    self.tableView.reloadData()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    if let error = error {
                        self.errorMsg.text = error
                    } else if videos?.count == 0 {
                        self.errorMsg.text = NSLocalizedString("conNoYoutubeVideos", comment: "No videos found for this request.")
                    }
                    self.errorView.hidden = false
                }
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func setHeaderFields() {
        
        if let song = song {
            searchLabel.text = String(format: NSLocalizedString("conYoutubeSearch", comment: "(searched YouTube for \"%0$@\")"), arguments: [song])
        }
        
        locationLabel.text =  gig.formatLocation()
        dateLabel.text = DateUtils.toDateStringMedium(gig.startDate)
        
        UrlFetcher.loadImageFromUrl(gig.band.fanartLogoUrl ?? "") { image in
            self.bandLogo.image = image
        }
    }
    
}
