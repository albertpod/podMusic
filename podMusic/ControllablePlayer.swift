//
//  ControllablePlayer.swift
//  podMusic
//
//  Created by Albert Podusenko on 17.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation
import AVFoundation

class ControllablePlayer {
    var player = AVPlayer()
    // for pause's purposes we have to watch on currentTrack
    var currentTrack = ""
    
    func playMusic(_ url: String!) {
        player.pause()
        player.rate = 0.0
        let playerItem = AVPlayerItem(url: URL(string: url)!)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1.0
        player.play()
    }
    
    func stopMusic(_ url: String!) {
        player.pause()
        player.rate = 0.0
    }
}
