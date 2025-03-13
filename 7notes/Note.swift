//
//  Note.swift
//  7notes
//
//  Created by Aleksandrs Bertulis on 11.03.25.
//

import Foundation
import SwiftData

@Model
class Note {
    var id: UUID = UUID()
    var text: String
    var category: Category?
    
    init(text: String, category: Category? = nil) {
        self.text = text
        self.category = category
    }
}
