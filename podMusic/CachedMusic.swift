//
//  cachedMusic.swift
//  podMusic
//
//  Created by Albert Podusenko on 16.09.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

/// Representation of entity in Realm db
class CachedMusic: Object {
    // Agreement: track is a pair of artist and song on the off-chance
    dynamic var artistName: String?
    dynamic var songName: String?
    // The following string points on the physical location of the track
    dynamic var trackPath: String?
    dynamic var trackImageUrl: String?
}
