//
//  NewNoteView.swift
//  7notes
//
//  Created by Aleksandrs Bertulis on 12.03.25.
//

import SwiftData
import SwiftUI

struct NewNoteView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var note: Note
    @Bindable var category: Category

    @State private var selectedColor: Color
    
    init(note: Note, category: Category) {
        self.note = note
        self.category = category
        _selectedColor = State(initialValue: Color(hex: category.colorHex))
    }
    
    var body: some View {
        TextField("Write your note", text: $note.text)
        CustomColorPicker(selectedColor: $selectedColor)
        TextField("Note Category", text: $category.name)
        Button("Save") {
            createNote()
        }
    }
    
    func createNote() {
        // Do not modify the original category, create a new instance of it
        let newCategory = Category(colorHex: selectedColor.toHex(), name: category.name)
        
        // Create the new note with the correct category
        let newNote = Note(text: note.text, category: newCategory)
        modelContext.insert(newNote)
    }
    
}

#Preview {
    do {
        let container = try ModelContainer(for: Note.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let category = Category(colorHex: "#D3D3D3", name: "Other")
        let note = Note(text: "Return of The King")
        
        return NewNoteView(note: note, category: category)
            .modelContainer(container) // Attach model container
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
