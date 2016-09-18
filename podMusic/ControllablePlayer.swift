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
    enum State {
        case play
        case stop
        case pause
    }
    
    var player = AVPlayer()
    // for pause's purposes we have to watch on currentTrack
    var currentTrack = ""
    var state = State.stop
    var time: CMTime?
    
    func playMusic(_ url: String!) {
        /*player.pause()
        player.rate = 0.0*/
        print(url)
        let playerItem = AVPlayerItem(url: URL(string: url)!)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1.0
        player.play()
        currentTrack = url
        state = .play
    }
    
    func pauseMusic() {
        player.pause()
        player.rate = 0.0
        time = player.currentTime()
        state = .pause
    }
}
