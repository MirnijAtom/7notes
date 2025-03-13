//
//  _notesApp.swift
//  7notes
//
//  Created by Aleksandrs Bertulis on 11.03.25.
//

import SwiftData
import SwiftUI

@main
struct _notesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Note.self, Category.self])
    }
}
