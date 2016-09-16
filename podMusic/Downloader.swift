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
    var url : URL?
    // will be used to do whatever is needed once download is complete
    var downloaded: cachedMusic
    
    init(informationCell: songCell) {
        let temp = cachedMusic()
        temp.artistName = informationCell.artistLbl.text
        temp.songName = informationCell.songLbl.text
        temp.trackPath = ""
        downloaded = temp
    }
    
    //is called once the download is complete
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //copy downloaded data to your documents directory with same names as source file
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destinationUrl = documentsUrl!.appendingPathComponent(url!.lastPathComponent)
        let dataFromURL = try? Data(contentsOf: location)
        try? dataFromURL?.write(to: destinationUrl, options: [.atomic])
        print(destinationUrl)
        downloaded.trackPath = destinationUrl.absoluteString
        let realm = try! Realm()
        try! realm.write {
            realm.add(downloaded)
        }
    }
    
    //this is to track progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
    }
    
    /*FIXME:
     
    // if there is an error during download this will be called
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if(error != nil)
        {
            //handle the error
            print("Download completed with error: \(error!.localizedDescription)");
        }
    }*/
    
    
    //method to be called to download
    func download(_ url: URL) {
        self.url = url
        //download identifier can be customized. I used the "ulr.absoluteString"
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: url.absoluteString)
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
    }
}
