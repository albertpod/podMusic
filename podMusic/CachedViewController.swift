//
//  CachedViewController.swift
//  podMusic
//
//  Created by Albert Podusenko on 17.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import RealmSwift

class CachedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cachedTableView: UITableView!
    
    func playMusicButton(_ sender: AnyObject) {
        let senderCell = TrackCell.getCell(sender, table: cachedTableView)
        if senderCell.trackUrl == podPlayer.currentTrack?.trackUrl {
            podPlayer.pauseMusic()
        } else {
            podPlayer.playMusic(senderCell)
        }
        self.cachedTableView.reloadData()
    }
    
    func deleteMusic(_ sender: AnyObject) {
        let senderCell = TrackCell.getCell(sender, table: cachedTableView)
        let realm = try! Realm()
        let objects = realm.objects(CachedMusic.self)
        for item in objects {
        // FIXME: replace with guard
            if item.trackPath! == senderCell.trackUrl {
                try! realm.write {
                    // delete file from path
                    deleteFile(fileUrl: senderCell.trackUrl!)
                    realm.delete(item)
                    updateTableView()
                    // modify music data
                }
            }
        }
    }
    
    /**
     Delete file from iPhone storage
     */
    func deleteFile(fileUrl: String) {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory) as [String]
            for filename in files {
                if filename == fileUrl {
                    let filePath = documentsDirectory + "/" + filename
                    print(filePath)
                    do {
                        try FileManager.default.removeItem(atPath: filePath)
                    } catch {
                        print("File manager error")
                    }
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    func updateTableView() {
        podPlayer.musicData.removeAll()
        let realm = try! Realm()
        let data = realm.objects(CachedMusic.self)
        for item in data {
            let entity = ["artist" : item.artistName!, "song" : item.songName!, "url" : item.trackPath!, "imageURL" : item.trackImageUrl!]
            podPlayer.musicData.append(entity)
        }
        DispatchQueue.main.async {
            self.cachedTableView.reloadData()
        }
    }
    
    func nextTrack(note: NSNotification) {
        cachedTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(CachedViewController.nextTrack), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: podPlayer.player.currentItem)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podPlayer.musicData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cachedTableView.dequeueReusableCell(withIdentifier: "CachedCell")! as! TrackCell
        if !podPlayer.musicData.isEmpty {
            cell.completeTrackCell(indexPath: indexPath, data: podPlayer.musicData)
            cell.playButton?.addTarget(self, action: #selector(CachedViewController.playMusicButton(_:)), for: .touchUpInside)
            cell.deleteTrack.addTarget(self, action: #selector(CachedViewController.deleteMusic(_:)), for: .touchUpInside)
        }
        return cell
    }

}
