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
    @IBOutlet weak var progressView: UIProgressView!
    var timer: Timer!
    // last time registered player's state
    var registeredPlayerState = ControllablePlayer.State.stop
    var delta: Float = 0
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
            //let duration = CMTimeGetSeconds((currentItem?.duration)!)
            let currentTime = Int(CMTimeGetSeconds((currentItem?.currentTime())!))
            let minutes = currentTime / 60
            let seconds = currentTime - minutes * 60
            progressView.progress += delta
            timeLbl.text = NSString(format: "%02d:%02d", minutes, seconds) as String
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
        progressView.progress = 0
        delta = Float(1.0 / (podPlayer.player.currentItem?.duration.seconds)!)
        let button = sender as! UIButton
        if button.currentTitle == "Next" {
            podPlayer.switchTrack(commandType: .next)
        } else {
            podPlayer.switchTrack(commandType: .prev)
        }
        self.updateName()
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
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            print("got it")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UIGestureRecognizer(target: self, action: Selector(("handleTap")))
        progressView.addGestureRecognizer(tap)
        progressView.progress = 0.0
        slider.maximumValue = Float((podPlayer.player.currentItem?.duration.seconds)!)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerViewController.updateTime), userInfo: nil, repeats: true)
        if podPlayer.state == .play {
            delta = Float(1.0 / (podPlayer.player.currentItem?.duration.seconds)!)
        }
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
