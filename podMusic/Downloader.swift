//
//  Downloader.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation
import RealmSwift
import NFDownloadButton
import UserNotifications

class Downloader : NSObject, URLSessionDownloadDelegate {
    
    let downloadAPI = "https://www.youtubeinmp3.com/fetch/?video="
    
    var url: URL?
    var downloaded: CachedMusic
    var downloadCell: DownloadCell!
    
    // handler for tracking dummy download with -1
    var totalBytesToload: Int64 = -1
    
    init(informationCell: DownloadCell) {
        let temp = CachedMusic()
        temp.artistName = informationCell.artistLbl.text
        temp.songName = informationCell.songLbl.text
        temp.trackPath = ""
        temp.trackImageUrl = informationCell.trackImageUrl!
        downloaded = temp
    }
    
    /**
     It is called once the download is complete
     The downloaded data is being saved to the iPhone storage and an object is being recorded to Realm database.
     */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard totalBytesToload > 1000 else {
            return
        }
        //copy downloaded data to your documents directory with same names as source file
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let songIdenfifier = UUID().uuidString + ".mp3"
        let destinationUrl = documentsUrl!.appendingPathComponent(songIdenfifier)
        let dataFromURL = try? Data(contentsOf: location)
        try? dataFromURL?.write(to: destinationUrl, options: [.atomic])
        /*guard downloadCell.circularSlider.maximumValue > 0 else {
            return
        }*/
        DispatchQueue(label: "save_track").async {
            let realm = try! Realm()
            self.downloaded.trackPath = songIdenfifier
            try! realm.write {
                realm.add(self.downloaded)
            }
            self.totalBytesToload = -1
        }
    }
    
    /** 
     This is to track progress
     */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //downloadCell.circularSlider.maximumValue = CGFloat(totalBytesExpectedToWrite)
        totalBytesToload = totalBytesExpectedToWrite
        if totalBytesToload > 1000 {
            DispatchQueue.main.async {
                print(totalBytesWritten, totalBytesExpectedToWrite)
                print(CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite))
                self.downloadCell.downloadButton.downloadPercent = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
                //self.downloadCell.circularSlider.endPointValue = CGFloat(totalBytesWritten)
            }
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {self.downloadCell.downloadButton.alpha = 0; self.downloadCell.errorLbl.alpha = 100})
            }
        }
    }
    
    /**
     Error handling during download
     */
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        if(error != nil)
        {
            print("Download completed with error: \(String(describing: error?.localizedDescription))");
        }
    }
    
    // if there is an error during download this will be called
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if error != nil {
            print("Error \(String(describing: error?.localizedDescription))")
        }
    }
    
    /**
     Method for file downloading
     */
    func performGet(_ param: String, _ cell: DownloadCell) {
        self.downloadCell = cell
        if self.url != nil {
            return
        }
        cell.downloadButton.downloadState = NFDownloadButtonState.readyToDownload
        self.url = URL(string: downloadAPI + param)
        print((self.url?.absoluteString)!)
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: (self.url?.absoluteString)!)
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: (self.url)!)
        task.resume()
    }
}
