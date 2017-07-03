//
//  songCell.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import YouTubePlayer
import AVFoundation
import SwipeCellKit

class TrackCell: SwipeTableViewCell {
    
    // The following string points on WEB location of the track
    var trackUrl: String?
    var trackImageUrl: String?
    // Agreement: track is a pair of artist and song on the off-chance
    @IBOutlet weak var songLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var playButton: UIButton?
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var youtubeView: YouTubePlayerView!
    var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
     Get the tapped cell
     */
    static func getCell(_ sender: AnyObject, table: UITableView) -> TrackCell {
        let position: CGPoint = sender.convert(CGPoint.zero, to: table)
        let indexPath = table.indexPathForRow(at: position)
        let cell: UITableViewCell = table.cellForRow(at: indexPath!)!
        let senderCell = cell as! TrackCell
        return senderCell
    }
    
    func disableAudioPlayer() {
        if youtubeView.playerState == .Playing {
            podPlayer.pauseMusic()
        }
    }
    
    
    /**
     Fill string fields 
     */
    func completeTrackCell(indexPath: IndexPath, data: [[String : String]]) {
        self.artistLbl.text = data[(indexPath as NSIndexPath).row]["artist"]
        self.songLbl.text = data[(indexPath as NSIndexPath).row]["song"]
        self.trackUrl = data[(indexPath as NSIndexPath).row]["url"]
        self.trackImageUrl = data[(indexPath as NSIndexPath).row]["imageURL"]
        if self.trackUrl?.range(of: "http") != nil {
            let myVideoURL = URL(string: self.trackUrl!)!
            youtubeView.loadVideoURL(myVideoURL)
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(TrackCell.disableAudioPlayer), userInfo: nil, repeats: true)
        }
        if let playButton = self.playButton {
            switch podPlayer.state {
            case .pause, .stop:
                playButton.setTitle("Play", for: .normal)
            default:
                if podPlayer.currentTrack?.trackUrl == self.trackUrl {
                    playButton.setTitle("Playing", for: .normal)
                } else {
                    playButton.setTitle("Play", for: .normal)
                }
            }
        }
    }
}
