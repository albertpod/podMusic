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
import SwipeCellKit

// number of music to return
let bound = 100

/// Controller for searching music in YouTube
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, URLSessionDownloadDelegate, UISearchBarDelegate, SwipeTableViewCellDelegate {
    
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    var defaultOptions = SwipeTableOptions()
    var downloader: Downloader?
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
                let entity = ["artist" : contents[0], "song" : contents[1], "id" : videoId, "url" : videoUrl, "imageURL": highPhoto]
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
    
    func updateBytes(senderCell: DownloadCell) {
        senderCell.circularSlider.endPointValue = CGFloat((downloader?.downloadedBytes)!)
    }
    
    func download(indexPath: IndexPath) {
        let senderCell = searchTableView.cellForRow(at: indexPath) as! DownloadCell
        if let url = senderCell.trackUrl {
            print(url)
            downloader = Downloader(informationCell: senderCell)
            downloader?.performGet(url)
            senderCell.circularSlider.maximumValue = CGFloat((downloader?.maxSize)!)
            senderCell.circularSlider.endPointValue = CGFloat(1916531)
            senderCell.circularSlider.alpha = 100
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
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "DownloadCell")! as! DownloadCell
        cell.delegate = self
        cell.completeDownloadCell(indexPath: indexPath, data: localMusicData)
        //cell.downloadButton.addTarget(self, action: #selector(SearchViewController.download(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction] {
        if orientation == .right {
            let download = SwipeAction(style: .default, title: nil) { action, indexPath in
                self.download(indexPath: indexPath)
            }
            configure(action: download, with: .download)
            return [download]
            // flag.hidesWhenSelected = false
            
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .drag
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
