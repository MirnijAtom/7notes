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
    
    @State private var newNote = Note(text: "")
    @State private var newCategory = Category(colorHex: "#D3D3D3", name: "")
    
    @State private var selectedCategory: Category?
    @State private var showEditView = false
    @State private var showNewNoteView = false
    @State private var showNewNoteForCategory = false
    @State private var selectedCategoryForNewNote: Category?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    Section {
                        Section {
                            Text(category.name)
                                .font(.title.bold())
                            
                            ForEach(category.notes) { note in
                                Text(note.text)
                            }
                            .onDelete { offsets in
                                deleteNote(at: offsets, from: category)
                            }
//                            .onTapGesture {
//                                selectedCategory = category
//                                showEditView = true
//                        }
                            
                            
                        HStack {
                            Spacer()
                            Button(action: {
                                openNewNoteForCategory(category)
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white) // Set icon color to white
                                    .padding(4) // Adds padding around the icon
                                    .background(
                                        ZStack {
                                            Color(hex: category.colorHex).opacity(0.5) // Adjust opacity for the color
                                                .clipShape(Circle()) // Ensures the background is circular
                                            Color.clear.background(.regularMaterial) // Apply ultra-thin material
                                                .clipShape(Circle()) // Keeps the background circular
                                        }
                                    )
                                    .shadow(radius: 1, x: 0, y: 0)
                            }
                            Spacer()
                        }
                    }
                    
                    }
                    .listRowBackground( ZStack {
                        Color(hex: category.colorHex).opacity(0.5)
                        Color.clear.background(.ultraThinMaterial)
                    })
                }
                .onDelete(perform: deleteCategory)
//                .onMove(perform: moveCategory)
                
//                Button("New note") {
//                    showNewNoteCreation.toggle()
//                }
                
                Button("New note") {
                    showNewNoteView.toggle()
                }
            }
            .navigationTitle("7Notes")
            .sheet(item: $selectedCategory) { category in
                CategoryEditView(category: category)
            }
            .sheet(isPresented: $showNewNoteView) {
                NewNoteView(note: newNote, category: newCategory)
                    .presentationDetents([.fraction(0.4)])
            }
            .sheet(isPresented: $showNewNoteForCategory) {
                if let categoryForNewNote = selectedCategoryForNewNote {
                    NewNoteView(note: Note(text: ""), category: categoryForNewNote)
                }
            }
            
            
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
    
    func openNewNoteForCategory(_ category: Category) {
        // Set the selected category for the new note
        selectedCategoryForNewNote = category
        
        // Now show the sheet
        showNewNoteForCategory = true
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
