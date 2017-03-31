//
//  searchViewController.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit

import AVFoundation

// number of music to return
let bound = 100

/// Controller for searching music in VK
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchTableView: UITableView!
    var localMusicData: [[String : String]] = [[:]]
    
    func playMusicButton(_ sender: AnyObject) {
        let senderCell = TrackCell.getCell(sender, table: searchTableView)
        podPlayer.musicData = localMusicData
        if senderCell.trackUrl == podPlayer.currentTrack?.trackUrl {
            podPlayer.pauseMusic()
        } else {
            podPlayer.playMusic(senderCell)
        }
        self.searchTableView.reloadData()
    }
    
    func download(_ sender: AnyObject) {
        let senderCell = TrackCell.getCell(sender, table: searchTableView)
        if let url = URL(string: senderCell.trackUrl!) {
            Downloader(informationCell: senderCell).download(url)
        }
    }
    
    // allows to get profile's songs from VK if parameters are empty, otherwise it returns specified in params songs
    /*func getSongs(_ parameters: [VK.Arg : String] = [:]) {
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
            self.localMusicData.removeAll()
            let musicNumber = response["count"].intValue
            if (musicNumber != 0) {
                var i = 0
                while i < musicNumber {
                    if response["items"][i, "artist"].stringValue == "" && response["items"][i, "song"].stringValue == "" {
                        break
                    }
                    let entity = ["artist" : response["items"][i, "artist"].stringValue, "song" : response["items"][i, "title"].stringValue, "url" : response["items"][i, "url"].stringValue]
                    self.localMusicData.append(entity)
                    i += 1
                }
            }
            DispatchQueue.main.async(execute: {
                self.searchTableView.reloadData()
            })
            print(self.localMusicData.count)
        }
        //req.description
        req.errorBlock = {
            error in print("SwiftyVK: searchSong fail \n \(error)")
        }
        req.send()
    }*/
    
    func nextTrack(note: NSNotification) {
        searchTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getSongs()
        let youtubeAPI = YouTubeAPI()
        youtubeAPI.performGetRequest(targetURL: "https://www.youtubeinmp3.com/fetch/?video=https://www.youtube.com/watch?v=ebzEEEdjHj0")
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.nextTrack), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: podPlayer.player.currentItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if localMusicData.isEmpty {
            return 0
        }
        return localMusicData[0].isEmpty ? 0 : localMusicData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "TrackCell")! as! TrackCell
        cell.completeTrackCell(indexPath: indexPath, data: localMusicData)
        cell.playButton.addTarget(self, action: #selector(SearchViewController.playMusicButton(_:)), for: .touchUpInside)
        cell.downloadButton.addTarget(self, action: #selector(SearchViewController.download(_:)), for: .touchUpInside)
        return cell
    }

}
