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
    
    var musicURL: URL?
    var phototURL: URL?
    var downloaded: CachedMusic
    var downloadCell: DownloadCell!
    
    // handler for tracking dummy download with -1
    var totalBytesToload: Int64 = -1
    
    init(informationCell: DownloadCell) {
        let temp = CachedMusic()
        temp.artistName = informationCell.artistLbl.text
        temp.songName = informationCell.songLbl.text
        temp.trackPath = ""
        temp.trackImagePath = ""
        downloaded = temp
    }
    
    func finishDownloading(url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            do {
                let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let photoIdenfifier = UUID().uuidString + ".png"
                let destinationUrl = documentsUrl!.appendingPathComponent(photoIdenfifier)
                if let pngImageData = UIImagePNGRepresentation(image) {
                    try pngImageData.write(to: destinationUrl, options: .atomic)
                    self.downloaded.trackImagePath = photoIdenfifier
                }
            } catch { }
            DispatchQueue(label: "save_track").async {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(self.downloaded)
                }
                self.totalBytesToload = -1
            }
        }.resume()
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
        self.downloaded.trackPath = songIdenfifier
        self.finishDownloading(url: self.phototURL!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
        /*guard downloadCell.circularSlider.maximumValue > 0 else {
            return
        }*/
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
        if self.musicURL != nil {
            return
        }
        cell.downloadButton.downloadState = NFDownloadButtonState.readyToDownload
        self.musicURL = URL(string: downloadAPI + param)
        self.phototURL = URL(string: cell.trackImageUrl!)
        print((self.musicURL?.absoluteString)!)
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: (self.musicURL?.absoluteString)!)
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: (self.musicURL)!)
        task.resume()
    }
}
