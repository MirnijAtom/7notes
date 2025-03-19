//
//  CategoryEditView.swift
//  7notes
//
//  Created by Aleksandrs Bertulis on 18.03.25.
//

import SwiftData
import SwiftUI

struct CategoryEditView: View {
    @Environment(\.modelContext) var modelContext
    
    @Bindable var category: Category
    
    var body: some View {
        List {
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
        
    }
    func deleteNote(at offsets: IndexSet, from category: Category) {
        for offset in offsets {
            let note = category.notes[offset]
            modelContext.delete(note)
        }
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Note.self, Category.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        // Create categories with initial order
        let restaurantCategory = Category(colorHex: "#FF0000", name: "Restaurants", order: 0)

        
        // Create notes and assign categories
        let note1 = Note(text: "Italian Bistro", category: restaurantCategory)
        let note2 = Note(text: "Sushi Palace", category: restaurantCategory)
        
        // Insert into model context
        container.mainContext.insert(restaurantCategory)
        
        container.mainContext.insert(note1)
        container.mainContext.insert(note2)
        
        return CategoryEditView(category: restaurantCategory)
            .modelContainer(container)
        
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
