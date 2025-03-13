//
//  ContentView.swift
//  7notes
//
//  Created by Aleksandrs Bertulis on 11.03.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Category.order, animation: .default) var categories: [Category]
    
    @State private var showNewNoteCreation = false
    @State private var newNote = Note(text: "")
    @State private var newCategory = Category(colorHex: "#D3D3D3", name: "Other")
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    Section {
                        Text(category.name)
                            .font(.title.bold())
                        
                        ForEach(category.notes) { note in
                                Text(note.text)
                        }
                        .onDelete { offsets in
                            deleteNote(at: offsets, from: category)
                        }
                    }
                    .listRowBackground( ZStack {
                        Color(hex: category.colorHex).opacity(0.5)
                        Color.clear.background(.ultraThinMaterial)
                    })
                }
                .onDelete(perform: deleteCategory)
                .onMove(perform: moveCategory)
                
                Button("New note") {
                    showNewNoteCreation.toggle()
                }
                
                Section {
                    if showNewNoteCreation {
                        NewNoteView(note: newNote, category: newCategory)
                    }
                }
            }
            .navigationTitle("7Notes")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    func deleteNote(at offsets: IndexSet, from category: Category) {
        for offset in offsets {
            let note = category.notes[offset]
            modelContext.delete(note)
        }
    }
    
    func deleteCategory(at offsets: IndexSet) {
        for offset in offsets {
            let category = categories[offset]
            for note in category.notes {
                modelContext.delete(note)
            }
            modelContext.delete(category)
        }
    }
    
    func moveCategory(from source: IndexSet, to destination: Int) {
        var revisedCategories = categories
        revisedCategories.move(fromOffsets: source, toOffset: destination)
        
        for (index, category) in revisedCategories.enumerated() {
            category.order = Int16(index)
        }
        
        try? modelContext.save()
    }
    
}

#Preview {
    do {
        let container = try ModelContainer(for: Note.self, Category.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        // Create categories with initial order
        let restaurantCategory = Category(colorHex: "#FF0000", name: "Restaurants", order: 0)
        let bookCategory = Category(colorHex: "#FFFF00", name: "Books", order: 1)
        let moviesCategory = Category(colorHex: "#0000FF", name: "Movies", order: 2)
        
        // Create notes and assign categories
        let note1 = Note(text: "Italian Bistro", category: restaurantCategory)
        let note2 = Note(text: "Sushi Palace", category: restaurantCategory)
        
        let note3 = Note(text: "Dune", category: bookCategory)
        
        let note4 = Note(text: "Inception", category: moviesCategory)
        let note5 = Note(text: "Interstellar", category: moviesCategory)
        
        // Insert into model context
        container.mainContext.insert(restaurantCategory)
        container.mainContext.insert(bookCategory)
        container.mainContext.insert(moviesCategory)
        
        container.mainContext.insert(note1)
        container.mainContext.insert(note2)
        container.mainContext.insert(note3)
        container.mainContext.insert(note4)
        container.mainContext.insert(note5)
        
        return ContentView()
            .modelContainer(container)
        
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
