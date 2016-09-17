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
import RealmSwift

// number of music to return
let bound = 100

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchTableView: UITableView!
    var musicData: [[String : String]] = [[:]]
    
    
    
    @IBAction func playButton(_ sender: AnyObject) {
    }
    
    @IBAction func downloadButton(_ sender: AnyObject) {
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
            self.musicData.removeAll()
            let musicNumber = response["count"].intValue
            if (musicNumber != 0) {
                var i = 0
                while i < musicNumber {
                    if response["items"][i, "artist"].stringValue == "" && response["items"][i, "song"].stringValue == "" {
                        break
                    }
                    let entity = ["artist" : response["items"][i, "artist"].stringValue, "song" : response["items"][i, "title"].stringValue, "url" : response["items"][i, "url"].stringValue]
                    self.musicData.append(entity)
                    i += 1
                }
            }
            DispatchQueue.main.async(execute: {
                self.searchTableView.reloadData()
            })
            print(self.musicData.count)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicData[0].isEmpty ? 0 : self.musicData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "SongCell")! as! SongCell
        cell.artistLbl.text = musicData[(indexPath as NSIndexPath).row]["artist"]
        cell.songLbl.text = musicData[(indexPath as NSIndexPath).row]["song"]
        cell.trackUrl = musicData[(indexPath as NSIndexPath).row]["url"]
        return cell
    }

}
