//
//  YouTubeAPI.swift
//  podMusic
//
//  Created by Albert Podusenko on 31.03.17.
//  Copyright © 2017 Albert Podusenko. All rights reserved.
//

import Foundation

class YouTubeAPI: NSObject, URLSessionDownloadDelegate {
    
    let youtubeKeyAPI = "AIzaSyCjXrcStj6oZPYNQ_dYH5hnDz0vuyUbqxU"
    
    var recievedData: [[String : String]] = [[:]]
    
    //is called once the download is complete
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
                let entity = ["artist" : title, "song" : title, "url" : videoId]
                recievedData.append(entity)
            }
//            let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
        } catch let error as NSError {
            print(error)
        }
        print("all")
        
//        try? dataFromURL?.write(to: destinationUrl, options: [.atomic])
        /*downloaded.trackPath = url!.lastPathComponent
        let realm = try! Realm()
        try! realm.write {
            realm.add(downloaded)
        }*/
    }
    
    //this is to track progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        print(totalBytesWritten)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        if(error != nil)
        {
            //handle the error
            print("Download completed with error: \(String(describing: error?.localizedDescription))");
        }
    }
    
    func performGetRequest(params: String? = nil) {
        var getAPI = ""
        if (params != nil) {
            getAPI = "https://www.googleapis.com/youtube/v3/search/?part=snippet&q=\(params!)&type=video&key=\(youtubeKeyAPI)"
        } else {
            getAPI = "https://www.googleapis.com/youtube/v3/search/?part=snippet&order=rating&type=video&key=\(youtubeKeyAPI)"
        }
        
        let url = URL(string: getAPI)
        
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: (url?.absoluteString)!)
        
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        let task = session.downloadTask(with: url!)

        
        task.resume()
    }
}

