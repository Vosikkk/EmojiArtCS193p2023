//
//  SelectEffect.swift
//  EmojiArt
//
//  Created by Саша Восколович on 23.01.2024.
//

import SwiftUI

struct SelectEffect: ViewModifier {
    
    var isSelected: Bool
    var scaledTo: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(isSelected ? ractangle : nil)
//           // .padding(1)
//            .border(isSelected ? .blue : .clear, width: Constant.lindeWidth / zoom)
    }
    
    private struct Constant {
        static let lindeWidth: CGFloat = 1.5
        static let cornerRadius: CGFloat = 8
    }
    
    private var ractangle: some View {
        RoundedRectangle(cornerRadius: Constant.cornerRadius / scaledTo)
            .strokeBorder(lineWidth: Constant.lindeWidth / scaledTo)
            .foregroundStyle(.blue)
            
    }
}

extension View {
    func selectEffect(isSelected: Bool, scaledTo: CGFloat) -> some View {
        modifier(SelectEffect(isSelected: isSelected, scaledTo: scaledTo))
    }
}
