//
//  CustomColorPicker.swift
//  7notes
//
//  Created by Aleksandrs Bertulis on 12.03.25.
//

import SwiftUI

struct CustomColorPicker: View {
    @Binding var selectedColor: Color
    private let colors: [Color] = [.red, .blue, .orange, .yellow, .purple, .mint, .green]
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(colors, id: \.self) { color in
                Circle()
                        .foregroundColor(color)
                        .frame(width: 30, height: 30)
                        .opacity(color == selectedColor ? 0.5 : 1.0)
                        .scaleEffect(color == selectedColor ? 1.1 : 1.0)
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(20)
            
        }
    }
}

#Preview {
    CustomColorPicker(selectedColor: .constant(.blue))
}
