//
//  PlayerViewController.swift
//  podMusic
//
//  Created by Albert Podusenko on 17.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var prevTrackButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    @IBOutlet weak var songNameLbl: UILabel!
    @IBOutlet weak var artistNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var playMusicButton: UIButton!
    @IBOutlet weak var songImage: UIImageView!

    var timer: Timer!
    // last time registered player's state
    var registeredPlayerState = ControllablePlayer.State.stop
    
    var currentImageUrl: String?
    /**
     Updates the playing music time
     */
    func updateTime() {
        if currentImageUrl != podPlayer.currentTrack?.trackImageURL {
            self.updateName()
        }
        switch podPlayer.state {
        case .pause, .stop:
            if registeredPlayerState == .play {
                DispatchQueue.main.async {
                    self.registeredPlayerState = .pause
                    self.playMusicButton.setTitle("Play", for: .normal)
                    self.playMusicButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
                }
            }
        default:
            let currentItem = podPlayer.player.currentItem
            let currentTime = Int(CMTimeGetSeconds((currentItem?.currentTime())!))
            let minutes = currentTime / 60
            let seconds = currentTime - minutes * 60
            timeLbl.text = NSString(format: "%02d:%02d", minutes, seconds) as String
            slider.value = Float(currentTime)
            if slider.value >= round(slider.maximumValue) {
                registeredPlayerState = .pause
            }
            if registeredPlayerState != .play {
                DispatchQueue.main.async {
                    self.registeredPlayerState = .play
                    self.playMusicButton.setTitle("Playing", for: .normal)
                    self.playMusicButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                    self.updateName()
                }
            }
        }
    }
    
    /**
     Switch current track. Depending on the sender this function switches track to the next or previous one.
     */
    func switchTrack(_ sender: AnyObject) {
        let button = sender as! UIButton
        if button.currentTitle == "Next" {
            podPlayer.switchTrack(commandType: .next)
        } else {
            podPlayer.switchTrack(commandType: .prev)
        }
        registeredPlayerState = .pause
    }
    
    func playPauseTrack(_ sender: AnyObject) {
        if podPlayer.state == .play {
            podPlayer.pauseMusic()
        } else if podPlayer.currentTrack != nil {
            podPlayer.player.rate = 1.0
            podPlayer.player.play()
            podPlayer.state = .play
        }
    }
    
    func updateName() {
        DispatchQueue.main.async {
            self.artistNameLbl.text = podPlayer.currentTrack?.trackArtist
            self.songNameLbl.text = podPlayer.currentTrack?.trackName
            if let urlString = podPlayer.currentTrack?.trackImageURL! {
                if self.currentImageUrl != urlString {
                    self.currentImageUrl = urlString
                    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path
                    let tempPath = documentsUrl! + "/" + urlString
                    self.songImage?.image = UIImage(contentsOfFile: tempPath)
                    self.songImage?.contentMode = .scaleAspectFill
                }
            } else {
                self.currentImageUrl = nil
            }
            if let song = podPlayer.player.currentItem {
                if !song.duration.seconds.isNaN {
                    self.slider.maximumValue = Float((song.duration.seconds))
                }
            }
        }
    }
    
    func handleTap(_ sender: UISlider) {
        print("touched2")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerViewController.updateTime), userInfo: nil, repeats: true)
        if podPlayer.currentTrack == nil {
            sender.value = 0
            return
        }
        let time = CMTimeMakeWithSeconds(Float64(slider.value), (podPlayer.player.currentItem?.asset.duration.timescale)!)
        podPlayer.player.seek(to: time)
    }
    
    func touched(_ sender: UISlider) {
        print("touched1", sender.value)
        timer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerViewController.updateTime), userInfo: nil, repeats: true)
        slider.addTarget(self, action: #selector(PlayerViewController.handleTap(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(PlayerViewController.touched(_:)), for: .touchDown)
        nextTrackButton.addTarget(self, action: #selector(PlayerViewController.switchTrack(_:)), for: .touchUpInside)
        prevTrackButton.addTarget(self, action: #selector(PlayerViewController.switchTrack(_:)), for: .touchUpInside)
        playMusicButton.addTarget(self, action: #selector(PlayerViewController.playPauseTrack(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("appear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
