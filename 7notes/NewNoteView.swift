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
    @Environment(\.dismiss) var dismiss
    @Bindable var note: Note
    @Bindable var category: Category

    @State private var selectedColor: Color
    
    init(note: Note, category: Category) {
        self.note = note
        self.category = category
        _selectedColor = State(initialValue: Color(hex: category.colorHex))
    }
    
    var body: some View {
        List {
            TextField("New category", text: $category.name)
            CustomColorPicker(selectedColor: $selectedColor)
            TextField("Write your note", text: $note.text)
            
        }
        Button("Save") {
            createNote()
            dismiss()
        }
    }
    
    func createNote() {
        do {
            // Try to find an existing category with the same name
            let existingCategories = try modelContext.fetch(FetchDescriptor<Category>())
            
            if let existingCategory = existingCategories.first(where: { $0.name == category.name }) {
                let newNote = Note(text: note.text, category: existingCategory)
                modelContext.insert(newNote)
            } else {
                // If no category exists, create a new one
                let newCategory = Category(colorHex: selectedColor.toHex(), name: category.name)
                let newNote = Note(text: note.text, category: newCategory)
                modelContext.insert(newCategory) // Save the new category
                modelContext.insert(newNote)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
        }
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
