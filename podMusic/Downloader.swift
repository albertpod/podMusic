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
        let destinationUrl = documentsUrl!.appendingPathComponent(url!.lastPathComponent)
        let dataFromURL = try? Data(contentsOf: location)
        try? dataFromURL?.write(to: destinationUrl, options: [.atomic])
        downloaded.trackPath = url!.lastPathComponent
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
            print("Download completed with error: \(error?.localizedDescription)");
        }
    }
    
    /*// if there is an error during download this will be called
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError) {
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

    
    //method to be called to download
    func download1(_ url: URL) {
        // create your document folder url
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // your destination file url
        let destination = documentsUrl.appendingPathComponent(url.lastPathComponent)
        // check if it exists before downloading it
        if FileManager().fileExists(atPath: destination.path) {
            print("The file already exists at path")
        } else {
            //  if the file doesn't exist
            //  just download the data from your url
            URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) in
                // after downloading your data you need to save it to your destination url
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("audio"),
                    let location = location, error == nil
                    else { return }
                do {
                    try FileManager.default.moveItem(at: location, to: destination)
                    print("file saved")
                    //CachedViewController.cachedTableView.reloadData()
                    self.downloaded.trackPath = destination.absoluteString
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(self.downloaded)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
        }
    }
}
