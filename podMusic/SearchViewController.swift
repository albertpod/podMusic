//
//  searchViewController.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import SwiftyVK
import AVFoundation

// number of music to return
let bound = 100

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchTableView: UITableView!
    var previousCell: TrackCell?
    
    // FIXME: badSolution - copy-past
    func playMusicButton(_ sender: AnyObject) {
        let senderCell = TrackCell.getCell(sender, table: searchTableView)
        switch podPlayer.state {
        case .pause, .stop:
            podPlayer.playMusic(senderCell)
            DispatchQueue.main.async {
                senderCell.playButton.setTitle("Playing", for: .normal)
            }
        default:
            if senderCell != self.previousCell {
                podPlayer.playMusic(senderCell)
                senderCell.playButton.setTitle("Playing", for: .normal)
                self.previousCell?.playButton.setTitle("Play", for: .normal)
            } else {
                podPlayer.pauseMusic()
                DispatchQueue.main.async {
                    senderCell.playButton.setTitle("Play", for: .normal)
                }
            }
        }
        if senderCell != self.previousCell {
            self.previousCell?.playButton.setTitle("Play", for: .normal)
        }
        self.previousCell = senderCell
    }
    
    func download(_ sender: AnyObject) {
        let senderCell = TrackCell.getCell(sender, table: searchTableView)
        if let url = URL(string: senderCell.trackUrl!) {
            Downloader(informationCell: senderCell).download(url)
        }
    }
    
    // allows to get profile's songs from VK if parameters are empty, otherwise it returns specified in params songs
    func getSongs(_ parameters: [VK.Arg : String] = [:]) {
        var req: Request
        if parameters.isEmpty {
            req = VK.API.Audio.get()
        } else {
            req = VK.API.Audio.search(parameters)
        }
        req.maxAttempts = 1
        req.timeout = 10
        req.asynchronous = true
        req.successBlock = {
            response in print("SwiftyVK: searchSong success \n \(response)")
            podPlayer.musicData.removeAll()
            let musicNumber = response["count"].intValue
            if (musicNumber != 0) {
                var i = 0
                while i < musicNumber {
                    if response["items"][i, "artist"].stringValue == "" && response["items"][i, "song"].stringValue == "" {
                        break
                    }
                    let entity = ["artist" : response["items"][i, "artist"].stringValue, "song" : response["items"][i, "title"].stringValue, "url" : response["items"][i, "url"].stringValue]
                    podPlayer.musicData.append(entity)
                    i += 1
                }
            }
            DispatchQueue.main.async(execute: {
                self.searchTableView.reloadData()
            })
            print(podPlayer.musicData.count)
        }
        //req.description
        req.errorBlock = {
            error in print("SwiftyVK: searchSong fail \n \(error)")
        }
        req.send()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSongs()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("will appear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podPlayer.musicData[0].isEmpty ? 0 : podPlayer.musicData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "TrackCell")! as! TrackCell
        cell.artistLbl.text = podPlayer.musicData[(indexPath as NSIndexPath).row]["artist"]
        cell.songLbl.text = podPlayer.musicData[(indexPath as NSIndexPath).row]["song"]
        cell.trackUrl = podPlayer.musicData[(indexPath as NSIndexPath).row]["url"]
        cell.playButton.addTarget(self, action: #selector(SearchViewController.playMusicButton(_:)), for: .touchUpInside)
        cell.downloadButton.addTarget(self, action: #selector(SearchViewController.download(_:)), for: .touchUpInside)
        return cell
    }

}
