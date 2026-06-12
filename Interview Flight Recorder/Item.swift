//
//  Item.swift
//  Interview Flight Recorder
//
//  Created by wyy on 2026/6/11.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
