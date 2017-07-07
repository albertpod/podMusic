//
//  DownloadCell.swift
//  podMusic
//
//  Created by Albert Podusenko on 03.07.17.
//  Copyright © 2017 Albert Podusenko. All rights reserved.
//

import UIKit
import YouTubePlayer
import AVFoundation
import SwipeCellKit
import NFDownloadButton

class DownloadCell: SwipeTableViewCell {
    
    // The following string points on WEB location of the track
    var trackUrl: String?
    var trackImageUrl: String?
    // Agreement: track is a pair of artist and song on the off-chance
    @IBOutlet weak var songLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var youtubeView: YouTubePlayerView!
    @IBOutlet weak var downloadButton: NFDownloadButton!
    var timer: Timer?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func disableAudioPlayer() {
        if youtubeView.playerState == .Playing {
            podPlayer.pauseMusic()
        }
    }
    
    /**
     Get the tapped cell
     */
    static func getCell(_ sender: AnyObject, table: UITableView) -> DownloadCell {
        let position: CGPoint = sender.convert(CGPoint.zero, to: table)
        let indexPath = table.indexPathForRow(at: position)
        let cell: UITableViewCell = table.cellForRow(at: indexPath!)!
        let senderCell = cell as! DownloadCell
        return senderCell
    }
    
    
    /**
     Fill string fields
     */
    func completeDownloadCell(indexPath: IndexPath, data: [[String : String]]) {
        self.artistLbl.text = data[(indexPath as NSIndexPath).row]["artist"]
        self.songLbl.text = data[(indexPath as NSIndexPath).row]["song"]
        if !(self.songLbl.text?.isEmpty)! {
            self.songLbl.text?.remove(at: (self.songLbl.text?.startIndex)!)
        }
        self.trackUrl = data[(indexPath as NSIndexPath).row]["url"]
        self.trackImageUrl = data[(indexPath as NSIndexPath).row]["imageURL"]
        /*self.circularSlider.alpha = 0
        self.circularSlider.isEnabled = false
        self.circularSlider.maximumValue = 100
        self.circularSlider.minimumValue = 0*/
        if self.trackUrl?.range(of: "http") != nil {
            let myVideoURL = URL(string: self.trackUrl!)!
            youtubeView.loadVideoURL(myVideoURL)
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(DownloadCell.disableAudioPlayer), userInfo: nil, repeats: true)
        }
    }
}

