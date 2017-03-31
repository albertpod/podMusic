//
//  YouTubeAPI.swift
//  podMusic
//
//  Created by Albert Podusenko on 31.03.17.
//  Copyright © 2017 Albert Podusenko. All rights reserved.
//

import Foundation

class YouTubeAPI: NSObject, URLSessionDownloadDelegate {
    
    //is called once the download is complete
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //copy downloaded data to your documents directory with same names as source file
        print("done")
//        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        let destinationUrl = documentsUrl!.appendingPathComponent(url!.lastPathComponent)
//        let dataFromURL = try? Data(contentsOf: location)
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
            print("Download completed with error: \(error?.localizedDescription)");
        }
    }
    
    func performGetRequest(targetURL: String) {
        //    var request = URLRequest(url: targetURL)
        //    request.httpMethod = "GET"
        
        let url = URL(string: targetURL)
        
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: (url?.absoluteString)!)
        
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        let task = session.downloadTask(with: url!)

        
        task.resume()
    }
}

