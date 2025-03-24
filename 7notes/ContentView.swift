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
    
    // New note/category states
    @State private var newNote = Note(text: "")
    @State private var newCategory = Category(colorHex: "#D3D3D3", name: "")
    
    // UI control states
    @State private var selectedCategory: Category?
    @State private var showNewNoteView = false
    @State private var showNewNoteForCategory = false
    @State private var selectedCategoryForNewNote: Category?

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
                        .onDelete { deleteNoteFrom(category, at: $0) }
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                handleAddNoteButtonTap(category)
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(
                                        ZStack {
                                            Color(hex: category.colorHex).opacity(0.5)
                                                .clipShape(Circle())
                                            Color.clear.background(.regularMaterial)
                                                .clipShape(Circle())
                                        }
                                    )
                                    .shadow(radius: 1)
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(backgroundForCategory(category))
                }
                .onDelete(perform: deleteCategory)

                Button(action: {
                    showNewNoteView.toggle()
                }) {
                    HStack {
                        Spacer()
                        Text("New note")
                        Spacer()
                    }
                }
            }
            .navigationTitle("7Notes")
            .sheet(item: $selectedCategory) { CategoryEditView(category: $0) }
            .sheet(isPresented: $showNewNoteView) {
                NewNoteView(note: newNote, category: newCategory)
                    .presentationDetents([.fraction(0.35)])
            }
            .onChange(of: selectedCategoryForNewNote) { newCategory in
                if newCategory != nil {
                    showNewNoteForCategory = true
                }
            }
            .sheet(isPresented: $showNewNoteForCategory) {
                if let category = selectedCategoryForNewNote {
                    newNoteInCategoryView(note: newNote, category: category)
                        .presentationDetents([.fraction(0.35)])
                } else {
                    Text("Error: No category found")
                }
            }
            .navigationBarItems(trailing: EditButton())
        }
    }

    // MARK: - Helpers
    private func backgroundForCategory(_ category: Category) -> some View {
        ZStack {
            Color(hex: category.colorHex).opacity(0.5)
            Color.clear.background(.ultraThinMaterial)
        }
    }
}

// MARK: - Actions
extension ContentView {
    private func handleAddNoteButtonTap(_ category: Category) {
        // Print category name and color when button is tapped
        print("Category: \(category.name), Color: \(category.colorHex)")
        
        selectedCategoryForNewNote = category
        newNote = Note(text: "") // Reset the note text to ensure it starts fresh
//        showNewNoteForCategory = true // Show the sheet for the selected category
    }
    
    private func deleteNoteFrom(_ category: Category, at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(category.notes[index])
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            category.notes.forEach { modelContext.delete($0) }
            modelContext.delete(category)
        }
    }
}
// MARK: - Preview
#Preview {
    do {
        let container = try ModelContainer(for: Note.self, Category.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        let restaurantCategory = Category(colorHex: "#FF0000", name: "Restaurants", order: 0)
        let bookCategory = Category(colorHex: "#FFFF00", name: "Books", order: 1)
        let moviesCategory = Category(colorHex: "#0000FF", name: "Movies", order: 2)

        let note1 = Note(text: "Italian Bistro", category: restaurantCategory)
        let note2 = Note(text: "Sushi Palace", category: restaurantCategory)
        let note3 = Note(text: "Dune", category: bookCategory)
        let note4 = Note(text: "Inception", category: moviesCategory)
        let note5 = Note(text: "Interstellar", category: moviesCategory)

        container.mainContext.insert(restaurantCategory)
        container.mainContext.insert(bookCategory)
        container.mainContext.insert(moviesCategory)
        
        container.mainContext.insert(note1)
        container.mainContext.insert(note2)
        container.mainContext.insert(note3)
        container.mainContext.insert(note4)
        container.mainContext.insert(note5)
        
        return ContentView().modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
