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
    var musicData: [[String : String]] = [[:]]
    var previousCell: TrackCell?
    
    // FIXME: badSolution - copy-past
    func playMusic(_ sender: AnyObject) {
        let senderCell = TrackCell.getCell(sender, table: cachedTableView)
        if let url = senderCell.trackUrl {
            // pause if the playButton was pressed on the playing track
            if podPlayer.currentTrack == url {
                // FIXME: pause
                podPlayer.pauseMusic()
                DispatchQueue.main.async {
                    senderCell.playButton.setTitle("Play", for: .normal)
                }
                return
            }
            podPlayer.playMusic(url)
            DispatchQueue.main.async {
                senderCell.playButton.setTitle("Playing", for: .normal)
            }
        }
    }
    
    func checkExistingFiles() {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory) as [String]
            for filename in files {
                let filePath = documentsDirectory + "/" + filename
                do {
                    let fileDictionary = try FileManager.default.attributesOfItem(atPath: filePath)
                    let size = fileDictionary[FileAttributeKey.size]
                    print ("\(size)")
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
        musicData.removeAll()
        checkExistingFiles()
        let realm = try! Realm()
        let data = realm.objects(CachedMusic.self)
        for item in data {
            musicData.append(["artist": item.artistName!, "song": item.songName!, "path": item.trackPath!])
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async(execute: {
            self.cachedTableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let data = realm.objects(CachedMusic.self)
        print(data.count)
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cachedTableView.dequeueReusableCell(withIdentifier: "CachedMusicCell")! as! TrackCell
        if !musicData.isEmpty {
            cell.songLbl.text = musicData[(indexPath as NSIndexPath).row]["song"]
            cell.artistLbl.text = musicData[(indexPath as NSIndexPath).row]["artist"]
            cell.trackUrl = musicData[(indexPath as NSIndexPath).row]["path"]!
            cell.playButton.addTarget(self, action: #selector(CachedViewController.playMusic(_:)), for: .touchUpInside)
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
