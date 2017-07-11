//
//  AppDelegate.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

let podPlayer = ControllablePlayer()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        UIApplication.shared.statusBarStyle = .lightContent
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.previousTrackCommand.isEnabled = true;
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(AppDelegate.prevTrack(note:)))

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(AppDelegate.nextTrack(note:)))

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(AppDelegate.playTrack(note:)))

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(AppDelegate.pauseTrack(note:)))
        
        return true
    }
    
//    override func remoteControlReceived(with event: UIEvent?) {
//        let rc = event!.subtype
//        print("does this work? \(rc.rawValue)")
//    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return true
    }
    
    func nextTrack(note: NSNotification) {
        podPlayer.switchTrack(commandType: .next)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
    }
    
    func prevTrack(note: NSNotification) {
        podPlayer.switchTrack(commandType: .prev)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
    }

    func playTrack(note: NSNotification) {
        podPlayer.resumeMusic()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
    }
    
    func pauseTrack(note: NSNotification) {
        podPlayer.pauseMusic()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

