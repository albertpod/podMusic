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
    /**
     Updates the playing music time
     */
    func updateTime() {
        switch podPlayer.state {
        case .pause, .stop:
            if registeredPlayerState == .play {
                DispatchQueue.main.async {
                    self.registeredPlayerState = .pause
                    self.playMusicButton.setTitle("Play", for: .normal)
                }
            }
        default:
            let currentItem = podPlayer.player.currentItem
            let currentTime = Int(CMTimeGetSeconds((currentItem?.currentTime())!))
            let minutes = currentTime / 60
            let seconds = currentTime - minutes * 60
            timeLbl.text = NSString(format: "%02d:%02d", minutes, seconds) as String
            slider.value = Float(currentTime)
            if registeredPlayerState != .play {
                DispatchQueue.main.async {
                    self.registeredPlayerState = .play
                    self.playMusicButton.setTitle("Playing", for: .normal)
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
            if let url = URL.init(string: (podPlayer.currentTrack?.trackImageURL)!) {
                self.songImage?.downloadedFrom(url: url)
            } else {
                self.songImage = nil
            }
        }
        if let song = podPlayer.player.currentItem {
            slider.maximumValue = Float((song.duration.seconds))
        }
    }
    
    func handleTap(_ sender: AnyObject) {
        print("touched", slider.value)
        let time = CMTimeMakeWithSeconds(Float64(slider.value), (podPlayer.player.currentItem?.asset.duration.timescale)!)
        podPlayer.player.seek(to: time)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateName()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerViewController.updateTime), userInfo: nil, repeats: true)
        slider.addTarget(self, action: #selector(PlayerViewController.handleTap(_:)), for: .touchUpInside)
        nextTrackButton.addTarget(self, action: #selector(PlayerViewController.switchTrack(_:)), for: .touchUpInside)
        prevTrackButton.addTarget(self, action: #selector(PlayerViewController.switchTrack(_:)), for: .touchUpInside)
        playMusicButton.addTarget(self, action: #selector(PlayerViewController.playPauseTrack(_:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("appear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
