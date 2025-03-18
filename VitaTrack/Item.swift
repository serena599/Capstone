//
//  Item.swift
//  VitaTrack
//
//  Created by 刘超 on 12/3/2025.
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
