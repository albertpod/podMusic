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

    @IBOutlet weak var songNameLbl: UILabel!
    @IBOutlet weak var artistNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var playMusicButton: UIButton!
    var timer: Timer!
    // last time registered player's state
    var registeredPlayerState = ControllablePlayer.State.stop
    
    // function updates the timew
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
            timeLbl.text = NSString(format: "%02d:%02d", minutes, seconds) as String
            if registeredPlayerState != .play {
                DispatchQueue.main.async {
                    self.registeredPlayerState = .play
                    self.playMusicButton.setTitle("Playing", for: .normal)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PlayerViewController.updateTime), userInfo: nil, repeats: true)
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
