//
//  newNoteInCategoryView.swift
//  7notes
//
//  Created by Aleksandrs Bertulis on 19.03.25.
//

import SwiftData
import SwiftUI

struct newNoteInCategoryView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Bindable var note: Note
    @Bindable var category: Category

    @State private var selectedColor: Color
    @FocusState private var isFocused: Bool
    
    init(note: Note, category: Category) {
        self.note = note
        self.category = category
        _selectedColor = State(initialValue: Color(hex: category.colorHex))
    }
    
    var body: some View {
        List {
            Section {
                Text(category.name)
                    .font(.title3.bold())
                TextField("Write your note", text: $note.text)
                    .focused($isFocused)
            }
            .onAppear {
                    isFocused = true  // Step 3: Activate keyboard
            }
            .listRowBackground( ZStack {
                Color(hex: category.colorHex).opacity(0.5)
                Color.clear.background(.ultraThinMaterial)
            })

            Button(action: {
                createNote()
                dismiss()
            }) {
                HStack {
                    Spacer()
                    Text("Save")
                    Spacer()
                }
            }
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
        let category = Category(colorHex: "#0000FF", name: "Movies")
        let note = Note(text: "Return of The King")
        
        return newNoteInCategoryView(note: note, category: category)
            .modelContainer(container) // Attach model container
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
