//
//  ControllablePlayer.swift
//  podMusic
//
//  Created by Albert Podusenko on 17.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation
import AVFoundation
import RealmSwift

class ControllablePlayer {
    enum State {
        case play
        case stop
        case pause
    }
    
    var player = AVQueuePlayer()

    // for pause's purposes we have to watch on currentTrack
    var currentTrack = ""
    var state = State.stop
    var time: CMTime?
    
    func playMusic(_ url: String!) {
        var temp = url!
        if (url.range(of: "https") == nil) {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString
            temp = documentsUrl! + temp
        }
        let playerItem = AVPlayerItem(url: URL(string: temp)!)
        player = AVQueuePlayer(items: [playerItem])
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
