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
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, URLSessionDownloadDelegate {

    @IBOutlet weak var searchTableView: UITableView!
    var localMusicData: [[String : String]] = [[:]]
    enum RequestType {
        case search
        case download
        case getRanking
    }
    
    
    let youtubeKeyAPI = "AIzaSyCjXrcStj6oZPYNQ_dYH5hnDz0vuyUbqxU"
    
    // this is to track progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        print(totalBytesWritten)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        if(error != nil)
        {
            // handle the error
            print("Download completed with error: \(String(describing: error?.localizedDescription))");
        }
    }
    
    // is called once the download is complete
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //copy downloaded data to your documents directory with same names as source file
        //        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        //        let destinationUrl = documentsUrl!.appendingPathComponent(url!.lastPathComponent)
        let dataFromURL = try? Data(contentsOf: location)
        do {
            let parsedData = try JSONSerialization.jsonObject(with: dataFromURL!, options: []) as! [String : Any]
            let items: AnyObject! = parsedData["items"] as AnyObject!
            for item in (items as! Array<AnyObject>) {
                let idField = item["id"] as! Dictionary<String, AnyObject>
                if ((idField["kind"] as! String).range(of: "video") == nil) {
                    continue
                }
                let videoId = idField["videoId"] as! String
                let snippetDict = item["snippet"] as! Dictionary<String, AnyObject>
                let title = snippetDict["title"] as! String
                var contents = title.components(separatedBy: "-")
                if contents.count < 2 {
                    contents.append("")
                }
                let entity = ["artist" : contents[1], "song" : contents[0], "url" : videoId]
                localMusicData.append(entity)
            }
            //            let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
        } catch let error as NSError {
            print(error)
        }
        self.searchTableView.reloadData()
        
        //        try? dataFromURL?.write(to: destinationUrl, options: [.atomic])
        /*downloaded.trackPath = url!.lastPathComponent
         let realm = try! Realm()
         try! realm.write {
         realm.add(downloaded)
         }*/
    }
    
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
        if let url = senderCell.trackUrl {
            print(url)
            Downloader(informationCell: senderCell).performGet(url)
        }
    }
    
    func performGetRequest(params: String? = nil) {
        var getAPI = ""
        if (params != nil) {
            getAPI = "https://www.googleapis.com/youtube/v3/search/?part=snippet&maxResults=30&q=\(params!)&type=video&key=\(youtubeKeyAPI)"
        } else {
            getAPI = "https://www.googleapis.com/youtube/v3/search/?part=snippet&maxResults=30&q=Paul%20Kalkbrenner&type=video&key=\(youtubeKeyAPI)"
        }
        
        let url = URL(string: getAPI)
        
        print((url?.absoluteString)!)
        
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: (url?.absoluteString)!)
        
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        let task = session.downloadTask(with: url!)
        
        
        task.resume()
    }
    
    func nextTrack(note: NSNotification) {
        searchTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localMusicData.removeAll()
//        let searchParams = "Paul%20Kalkbrenner".replacingOccurrences(of: " ", with: "%20")
        performGetRequest()
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
