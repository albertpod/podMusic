//
//  searchViewController.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import UIKit
import YouTubePlayer
import AVFoundation

// number of music to return
let bound = 100

/// Controller for searching music in YouTube
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, URLSessionDownloadDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    var localMusicData: [[String : String]] = [[:]]
    enum RequestType {
        case search
        case download
        case getRanking
    }
    
    
    let youtubeKeyAPI = "AIzaSyCjXrcStj6oZPYNQ_dYH5hnDz0vuyUbqxU"
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        print(totalBytesWritten)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        if(error != nil)
        {
            print("Download completed with error: \(String(describing: error?.localizedDescription))");
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        localMusicData.removeAll()
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
                let videoUrl = "https://www.youtube.com/watch?v=\(videoId)"
                let snippetDict = item["snippet"] as! Dictionary<String, AnyObject>
                let title = snippetDict["title"] as! String
                let thumbnails = snippetDict["thumbnails"] as! Dictionary<String, AnyObject>
                let photos = [thumbnails["medium"] as! Dictionary<String, AnyObject>, thumbnails["high"] as! Dictionary<String, AnyObject>]
                let highPhoto = photos[1]["url"] as! String
                var contents = title.components(separatedBy: "-")
                if contents.count < 2 {
                    contents.append("")
                }
                let entity = ["artist" : contents[1], "song" : contents[0], "id" : videoId, "url" : videoUrl, "imageURL": highPhoto]
                localMusicData.append(entity)
            }
        } catch let error as NSError {
            print(error)
        }
        DispatchQueue.main.async {
            self.searchTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchParams = searchBar.text?.replacingOccurrences(of: " ", with: "%20")
        performGetRequest(params: searchParams)
        searchTableView.reloadData()
        searchBar.endEditing(true)
        searchBar.text = ""
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
        
        getAPI = getAPI.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        
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
        searchBar.delegate = self
        searchBar.showsScopeBar = true
        localMusicData.removeAll()
        performGetRequest()
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.nextTrack), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: podPlayer.player.currentItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        //cell.playButton.addTarget(self, action: #selector(SearchViewController.playMusicButton(_:)), for: .touchUpInside)
        //cell.downloadButton.addTarget(self, action: #selector(SearchViewController.download(_:)), for: .touchUpInside)
        return cell
    }

}
