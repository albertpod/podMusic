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
    var previousCell: TrackCell?
    
    func playMusicButton(_ sender: AnyObject) {
        let senderCell = TrackCell.getCell(sender, table: cachedTableView)
        if senderCell.trackUrl == podPlayer.currentTrack?.trackUrl {
            podPlayer.pauseMusic()
        } else {
            podPlayer.playMusic(senderCell)
        }
        self.cachedTableView.reloadData()
    }
    
    
    
    func checkExistingFiles() {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory) as [String]
            for filename in files {
                let filePath = documentsDirectory + "/" + filename
                print(filePath)
                do {
                    let fileDictionary = try FileManager.default.attributesOfItem(atPath: filePath)
                    let size = fileDictionary[FileAttributeKey.size]
                    print ("Size is \(size)")
                } catch {
                    print("File manager error")
                }
            }
            
        } catch {
            print(error)
        }
        
        let realm = try! Realm()
        let data = realm.objects(CachedMusic.self)
        for item in data {
            let entity = ["artist" : item.artistName!, "song" : item.songName!, "url" : item.trackPath!]
            podPlayer.musicData.append(entity)
        }
    }
    
    func nextTrack(note: NSNotification) {
        cachedTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        podPlayer.musicData.removeAll()
        checkExistingFiles()
        NotificationCenter.default.addObserver(self, selector: #selector(CachedViewController.nextTrack), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: podPlayer.player.currentItem)
        // Do any additional setup after loading the view.
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
            cell.playButton.addTarget(self, action: #selector(CachedViewController.playMusicButton(_:)), for: .touchUpInside)
        }
        return cell
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
