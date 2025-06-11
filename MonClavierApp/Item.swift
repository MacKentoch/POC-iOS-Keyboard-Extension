//
//  Item.swift
//  MonClavierApp
//
//  Created by Rav3n on 11/06/2025.
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
