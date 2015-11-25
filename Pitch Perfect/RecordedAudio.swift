//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Nicholas Credli on 11/24/15.
//  Copyright © 2015 Novium Collective SARL. All rights reserved.
//

import Foundation

final class RecordedAudio {
    var filePathUrl: NSURL!
    var title: String!
    
    init(title: String, url: NSURL) {
        self.title = title
        filePathUrl = url
    }
    
    init(url: NSURL) {
        title = url.lastPathComponent
        filePathUrl = url
    }
}