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
        podPlayer.playMusic(senderCell)
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        podPlayer.musicData.removeAll()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        podPlayer.musicData.removeAll()
        let realm = try! Realm()
        let data = realm.objects(CachedMusic.self)
        for item in data {
            let entity = ["artist" : item.artistName!, "song" : item.songName!, "url" : item.trackPath!]
            podPlayer.musicData.append(entity)
        }
        //self.cachedTableView.reloadData()
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
            cell.songLbl.text = podPlayer.musicData[(indexPath as NSIndexPath).row]["song"]
            cell.artistLbl.text = podPlayer.musicData[(indexPath as NSIndexPath).row]["artist"]
            cell.trackUrl = podPlayer.musicData[(indexPath as NSIndexPath).row]["url"]!
            cell.playButton.addTarget(self, action: #selector(CachedViewController.playMusicButton(_:)), for: .touchUpInside)
            switch podPlayer.state {
            case .pause, .stop:
                cell.playButton.setTitle("Play", for: .normal)
            default:
                if podPlayer.currentTrack?.trackUrl == cell.trackUrl {
                    cell.playButton.setTitle("Playing", for: .normal)
                } else {
                    cell.playButton.setTitle("Play", for: .normal)
                }
            }
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
