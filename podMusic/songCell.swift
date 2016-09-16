//
//  songCell.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit

class songCell: UITableViewCell {
    
    // The following string points on WEB location of the track
    var trackUrl: String?
    // Agreement: track is a pair of artist and song on the off-chance
    @IBOutlet weak var songLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
