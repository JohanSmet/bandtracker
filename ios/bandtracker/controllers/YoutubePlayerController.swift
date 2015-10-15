//
//  YoutubePlayerController.swift
//  bandtracker
//
//  Created by Johan Smet on 15/10/15.
//  Copyright © 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class YoutubePlayerController : UIViewController,
                                YouTubePlayerDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var video : YoutubeDataClient.Video!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // class functions
    //
    
    static func createForVideo(video : YoutubeDataClient.Video) -> YoutubePlayerController {
        let storyboard = UIStoryboard(name: "Gigs", bundle: nil)
        let player = storyboard.instantiateViewControllerWithIdentifier("YoutubePlayerController") as! YoutubePlayerController
        player.video = video
        
        return player
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        youtubePlayer.delegate = self
        youtubePlayer.loadVideoID(video.id)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // YoutubePlayerDelegate
    //
    
    func playerReady(videoPlayer: YouTubePlayerView) {
        videoPlayer.play()
    }
    
    func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        
    }
    
    func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
    
    
}