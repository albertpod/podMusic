//
//  Downloader.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation
import RealmSwift

class Downloader : NSObject, URLSessionDownloadDelegate {
    
    let downloadAPI = "https://www.youtubeinmp3.com/fetch/?video=https://www.youtube.com/watch?v="
    
    var url : URL?
    // will be used to do whatever is needed once download is complete
    var downloaded: CachedMusic

    //public func download(method: Method, URLString: URLStringConvertible, destination: Request.DownloadFileDestination) -> Request
    
    init(informationCell: TrackCell) {
        let temp = CachedMusic()
        temp.artistName = informationCell.artistLbl.text
        temp.songName = informationCell.songLbl.text
        temp.trackPath = ""
        downloaded = temp
    }
    
    //is called once the download is complete
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //copy downloaded data to your documents directory with same names as source file
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let songIdenfifier = UUID().uuidString + ".mp3"
        let destinationUrl = documentsUrl!.appendingPathComponent(songIdenfifier)
        let dataFromURL = try? Data(contentsOf: location)
        try? dataFromURL?.write(to: destinationUrl, options: [.atomic])
        downloaded.trackPath = songIdenfifier
        let realm = try! Realm()
        try! realm.write {
            realm.add(downloaded)
        }
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
    
    // if there is an error during download this will be called
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if error != nil {
            print("Error \(String(describing: error?.localizedDescription))")
        }
    }
    
    //method to be called to download
    func performGet(_ param: String) {
        self.url = URL(string: downloadAPI + param)
        print((self.url?.absoluteString)!)
        //download identifier can be customized. I used the "ulr.absoluteString"
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: (self.url?.absoluteString)!)
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: (self.url)!)
        task.resume()
    }
}
