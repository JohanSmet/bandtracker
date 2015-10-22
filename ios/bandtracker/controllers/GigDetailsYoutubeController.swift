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
                                    UITableViewDelegate,
                                    GigDetailsSubView {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var gig         : Gig!
    var song        : String!
    
    var delegate    : GigDetailsSubViewDelegate!
    var videos      : [YoutubeDataClient.Video] = []
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        tableView.dataSource = self
        tableView.delegate   = self
        
        // load the videos
        searchForVideos()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
        guard let delegate = delegate else { return }
        
        // check if list has to be refreshed
        let newSong = delegate.youtubeSong()
        if song != newSong {
            song = newSong
            searchForVideos()
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vc = YoutubePlayerController.createForVideo(videos[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
        
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
        
        UrlFetcher.loadImageFromUrl(video.thumbUrl) { image in
            cell.thumbnail.image = image
        }
        
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    func searchForVideos() {
        youtubeDataClient().searchVideosForGig(gig, song: song, maxResults: 10) { videos, error in
            if let videos = videos {
                self.videos = videos
                self.tableView.reloadData()
            }
        }
    }
    
}
