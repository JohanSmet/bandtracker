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
                                    GigDetailsSubView {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var gig     : Gig!
    var videos  : [YoutubeDataClient.Video] = []
    
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
        
        // load the videos
        youtubeDataClient().searchVideosForGig(gig, song: nil, maxResults: 10) { videos, error in
            if let videos = videos {
                self.videos = videos
            }
        }
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
    
}
