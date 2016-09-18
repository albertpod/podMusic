//
//  Downloader.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation
import RealmSwift

class Downloader : NSObject {
    // will be used to do whatever is needed once download is complete
    var downloaded: CachedMusic
    
    init(informationCell: TrackCell) {
        let temp = CachedMusic()
        temp.artistName = informationCell.artistLbl.text
        temp.songName = informationCell.songLbl.text
        temp.trackPath = ""
        downloaded = temp
    }
    
    //method to be called to download
    func download(_ url: URL) {
        // create your document folder url
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // your destination file url
        let destination = documentsUrl.appendingPathComponent(url.lastPathComponent)
        print(destination)
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
