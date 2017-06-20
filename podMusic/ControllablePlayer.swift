//
//  ControllablePlayer.swift
//  podMusic
//
//  Created by Albert Podusenko on 17.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

/// Player of the application
class ControllablePlayer {
    
    /**
     Command type for the switcher.
     
     - next: switch to the next track.
     - prev: switch to the prev track.
     */
    enum switchCommand {
        case next, prev
    }
    
    /**
     State of the player.
     
     - play: player is playing music now.
     - stop: player is not playing at all
     - pause: player is on the pause mode
     */
    enum State {
        case play, stop, pause
    }
    
    /** Structure which contains the name of the song and artist, it's identifier(url)
     and it's position in the playable track list */
    struct MusicNode {
        var (trackName, trackArtist, trackUrl, trackImageURL, trackPostionInList): (String?, String?, String?, String?, Int?)
    }
    
    var currentTrack: MusicNode?
    var player = AVPlayer()
    // State of the player. Stop by default
    var state = State.stop
    // Playing list
    var musicData: [[String : String]] = [[:]]
    
    /**
     Search for the particular MusicNode in musicData list
     
     - Parameter url:  Identifier of track.
     
     - Returns: Desired.
     */
    func searchForTrack(url: String) -> MusicNode? {
        var temp = MusicNode()
        for (index, item) in musicData.enumerated() {
            if item["url"] == url {
                temp.trackPostionInList = index
                temp.trackArtist = item["artist"]!
                temp.trackName = item["song"]!
                temp.trackUrl = url
                temp.trackImageURL = item["imageURL"]
                return temp
            }
        }
        return temp
    }
    
    /**
     Play music method
     
     - Parameter cell:  TrackCell to play.
     
     */
    func playMusic(_ cell: TrackCell!) {
        var temp: String!
        
        // Fill all fields in currentTrack variable
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
    
    /**
     Pause the music
     */
    func pauseMusic() {
        player.pause()
        player.rate = 0.0
        //currentTrack = nil
        state = .pause
    }
    
    /**
     Switch the track in the current musicData list
     
     - Parameter commandType:  switch to the next or previous track in list.
     
     */
    func switchTrack(commandType: switchCommand) {
        var margin: Int
        switch commandType {
        case .next:
            if (currentTrack?.trackPostionInList)! >= (musicData.count - 1) {
                return
            }
            margin = 1
        default:
            if (currentTrack?.trackPostionInList)! == 0 {
                return
            }
            margin = -1
        }
        var temp = MusicNode()
        var tempUrl: String
        temp.trackArtist = musicData[(currentTrack?.trackPostionInList)! + margin]["artist"]!
        temp.trackName = musicData[(currentTrack?.trackPostionInList)! + margin]["song"]!
        temp.trackUrl = musicData[(currentTrack?.trackPostionInList)! + margin]["url"]!
        temp.trackImageURL = musicData[(currentTrack?.trackPostionInList)! + margin]["imageURL"]!
        tempUrl = temp.trackUrl!
        temp.trackPostionInList = (currentTrack?.trackPostionInList)! + margin
        if (temp.trackUrl?.range(of: "https") == nil) {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString
            tempUrl = documentsUrl! + tempUrl
        }
        pauseMusic()
        currentTrack = temp
        player = AVPlayer(playerItem: AVPlayerItem(url: URL(string: tempUrl)!))
        player.rate = 1.0
        player.play()
        state = .play
    }
}
