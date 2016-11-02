//
//  songCell.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit

class TrackCell: UITableViewCell {
    
    // The following string points on WEB location of the track
    var trackUrl: String?
    // Agreement: track is a pair of artist and song on the off-chance
    @IBOutlet weak var songLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var deleteTrack: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func getCell(_ sender: AnyObject, table: UITableView) -> TrackCell {
        let position: CGPoint = sender.convert(CGPoint.zero, to: table)
        let indexPath = table.indexPathForRow(at: position)
        let cell: UITableViewCell = table.cellForRow(at: indexPath!)!
        let senderCell = cell as! TrackCell
        return senderCell
    }
    
    /* Fill string fields */
    func completeTrackCell(indexPath: IndexPath, data: [[String : String]]) {
        self.artistLbl.text = data[(indexPath as NSIndexPath).row]["artist"]
        self.songLbl.text = data[(indexPath as NSIndexPath).row]["song"]
        self.trackUrl = data[(indexPath as NSIndexPath).row]["url"]
        switch podPlayer.state {
        case .pause, .stop:
            self.playButton.setTitle("Play", for: .normal)
        default:
            if podPlayer.currentTrack?.trackUrl == self.trackUrl {
                self.playButton.setTitle("Playing", for: .normal)
            } else {
                self.playButton.setTitle("Play", for: .normal)
            }
        }
    }
}
