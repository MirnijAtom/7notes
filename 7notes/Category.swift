//
//  Category.swift
//  7notes
//
//  Created by Aleksandrs Bertulis on 11.03.25.
//

import SwiftData
import Foundation

@Model
class Category {
    var id: UUID = UUID()
    var colorHex: String
    var name: String
    var notes: [Note] = []
    var order: Int16
    
    init(colorHex: String, name: String, order: Int16 = 0) {
        self.colorHex = colorHex
        self.name = name
        self.order = order
    }
}
