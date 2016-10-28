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
    
    struct MusicNode {
        var (trackName, trackAuthor, trackUrl, trackPostionInList): (String?, String?, String?, Int?)
    }
    
    var currentTrack: MusicNode?
    var player = AVPlayer()
    var state = State.stop
    var musicData: [[String : String]] = [[:]]
    
    /* Search for track info in current musicData's array */
    func searchForTrack(url: String) -> MusicNode? {
        var temp = MusicNode()
        for (index, item) in musicData.enumerated() {
            if item["url"] == url {
                temp.trackPostionInList = index
                temp.trackAuthor = item["artist"]!
                temp.trackName = item["song"]!
                temp.trackUrl = url
                return temp
            }
        }
        return temp
    }
    
    
    func playMusic(_ cell: TrackCell!) {
        var temp: String!
        
        /* Fill all fields in currentTrack variable*/
        currentTrack = searchForTrack(url: (cell.trackUrl)!)
        temp = currentTrack?.trackUrl
        
        if (currentTrack?.trackUrl?.range(of: "https") == nil) {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString
            temp = documentsUrl! + temp
        }
        let playerItem = AVPlayerItem(url: URL(string: temp)!)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1.0
        player.play()
        state = .play
    }
    
    func pauseMusic() {
        player.pause()
        player.rate = 0.0
        state = .pause
    }
    
    /* switchers. It's better to combine them due to the copy-past */
    func nextTrack() {
        if (currentTrack?.trackPostionInList)! < (musicData.count - 1) {
            var temp = MusicNode()
            var tempUrl: String
            temp.trackAuthor = musicData[(currentTrack?.trackPostionInList)! + 1]["author"]!
            temp.trackName = musicData[(currentTrack?.trackPostionInList)! + 1]["song"]!
            temp.trackUrl = musicData[(currentTrack?.trackPostionInList)! + 1]["url"]!
            tempUrl = temp.trackUrl!
            temp.trackPostionInList = (currentTrack?.trackPostionInList)! + 1
            if (temp.trackUrl?.range(of: "https") == nil) {
                let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString
                tempUrl = documentsUrl! + tempUrl
            }
            pauseMusic()
            player = AVPlayer(playerItem: AVPlayerItem(url: URL(string: tempUrl)!))
            player.rate = 1.0
            player.play()
            state = .play
        }
    }
    
    func prevTrack() {
        if (currentTrack?.trackPostionInList)! > 0 {
            var temp = MusicNode()
            var tempUrl: String
            temp.trackAuthor = musicData[(currentTrack?.trackPostionInList)! - 1]["author"]!
            temp.trackName = musicData[(currentTrack?.trackPostionInList)! - 1]["song"]!
            temp.trackUrl = musicData[(currentTrack?.trackPostionInList)! - 1]["url"]!
            tempUrl = temp.trackUrl!
            temp.trackPostionInList = (currentTrack?.trackPostionInList)! - 1
            if (temp.trackUrl?.range(of: "https") == nil) {
                let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString
                tempUrl = documentsUrl! + tempUrl
            }
            pauseMusic()
            player = AVPlayer(playerItem: AVPlayerItem(url: URL(string: tempUrl)!))
            player.rate = 1.0
            player.play()
            state = .play
        }
    }
}
