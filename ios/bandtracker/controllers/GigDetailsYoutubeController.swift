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
    
    fileprivate var gig         : Gig!
    fileprivate var song        : String!
    
    fileprivate var videos      : [YoutubeDataClient.Video] = []
    fileprivate var error       : String = ""
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bandLogo: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // static interface
    //
    
    class func create(_ gig : Gig, song : String? = nil) -> GigDetailsYoutubeController {
        
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        
        let newVC = storyboard.instantiateViewController(withIdentifier: "GigDetailsYoutubeController") as! GigDetailsYoutubeController
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
        tableView.isHidden     = true
        
        // load the videos
        searchForVideos()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource
    //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let numSections = videos.isEmpty ? 0 : 1
            
        if error.isEmpty {
            TableViewUtils.messageEmptyTable(tableView, isEmpty: numSections == 0, message: NSLocalizedString("conNoYoutubeVideos", comment: "No videos found for this request."))
        } else {
            TableViewUtils.messageEmptyTable(tableView, isEmpty: true, message: error)
        }
        
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "YoutubeCell", for: indexPath) as! YoutubeTableViewCell
        let video = self.videos[indexPath.row]
        
        cell.videoTitle!.text = video.title
        cell.videoPlayer.loadVideoID(video.id)
        
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    fileprivate func searchForVideos() {
        youtubeDataClient().searchVideosForGig(gig, song: song, maxResults: 10) { videos, error in
            DispatchQueue.main.async {
                
                if let videos = videos {
                    self.videos = videos
                } else {
                    self.videos = []
                }
                
                if let error = error {
                    self.error = error
                } else {
                    self.error = ""
                }
                
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func setHeaderFields() {
        
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
