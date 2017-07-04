//
//  CachedViewController.swift
//  podMusic
//
//  Created by Albert Podusenko on 17.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import RealmSwift
import CoreMedia
import SwipeCellKit

class CachedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {

    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    var defaultOptions = SwipeTableOptions()

    @IBOutlet weak var cachedTableView: UITableView!
    
    var timer: Timer!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(CachedViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        self.cachedTableView.reloadData()
        updateTableView()
        refreshControl.endRefreshing()
    }
    
    func updater() {
        if let song = podPlayer.player.currentItem {
            if song.duration.seconds <= CMTimeGetSeconds(song.currentTime()) {
                podPlayer.switchTrack(commandType: .next)
                updateTableView()
            }
        }
    }
    
    func playMusicButton(_ sender: AnyObject) {
        let senderCell = TrackCell.getCell(sender, table: cachedTableView)
        if senderCell.trackUrl == podPlayer.currentTrack?.trackUrl {
            podPlayer.pauseMusic()
        } else {
            podPlayer.playMusic(senderCell)
        }
        self.cachedTableView.reloadData()
    }
    
    func deleteMusic(index: IndexPath) {
        let senderCell = cachedTableView.cellForRow(at: index) as! TrackCell
        DispatchQueue(label: "albertpod.podMusic").sync {
            let realm = try! Realm()
            let objects = realm.objects(CachedMusic.self)
            for item in objects {
                // FIXME: replace with guard
                if item.trackPath! == senderCell.trackUrl {
                    try! realm.write {
                        // delete file from path
                        self.deleteFile(fileUrl: senderCell.trackUrl!)
                        realm.delete(item)
                        // modify music data
                    }
                }
            }
        }
        self.updateTableView()
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
        DispatchQueue(label: "albertpod.podMusic").sync {
            let realm = try! Realm()
            let data = realm.objects(CachedMusic.self)
            for item in data {
                let entity = ["artist" : item.artistName!, "song" : item.songName!, "url" : item.trackPath!, "imageURL" : item.trackImageUrl!]
                podPlayer.musicData.append(entity)
            }
            self.cachedTableView.reloadData()
        }
    }
    
    func nextTrack(note: NSNotification) {
        self.cachedTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        podPlayer.musicData.removeAll()
        NotificationCenter.default.addObserver(self, selector: #selector(CachedViewController.nextTrack), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: podPlayer.player.currentItem)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(CachedViewController.updater), userInfo: nil, repeats: true)
        cachedTableView.addSubview(refreshControl)
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
        cell.delegate = self
        if !podPlayer.musicData.isEmpty {
            cell.completeTrackCell(indexPath: indexPath, data: podPlayer.musicData)
            cell.playButton?.addTarget(self, action: #selector(CachedViewController.playMusicButton(_:)), for: .touchUpInside)
            //cell.deleteTrack.addTarget(self, action: #selector(CachedViewController.deleteMusic(_:)), for: .touchUpInside)
        }
        return cell
    }
    

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction] {
        if orientation == .right {
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.deleteMusic(index: indexPath)
            }
            configure(action: delete, with: .trash)
            return [delete]
            // flag.hidesWhenSelected = false
            
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = orientation == .left ? .none : .destructive
        options.transitionStyle = defaultOptions.transitionStyle
        print("swiped")
        return options
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 10)
        }
    }

}
