//
//  SelectEffect.swift
//  EmojiArt
//
//  Created by Саша Восколович on 23.01.2024.
//

import SwiftUI

struct SelectedEffect: ViewModifier {
    
    var isSelected: Bool
    var scaleFactor: CGFloat
    
    init(_ isSelected: Bool, scaleFactor: CGFloat) {
        self.isSelected = isSelected
        self.scaleFactor = scaleFactor
    }
    
    
    
    func body(content: Content) -> some View {
        content
            .overlay(isSelected ? ractangle : nil)
    }
    
    private struct Constant {
        static let lindeWidth: CGFloat = 1.5
        static let cornerRadius: CGFloat = 8
    }
    
    private var ractangle: some View {
        RoundedRectangle(cornerRadius: Constant.cornerRadius / scaleFactor)
            .strokeBorder(lineWidth: Constant.lindeWidth / scaleFactor)
            .foregroundStyle(.blue)
            
    }
}

extension View {
    func selectedEffect(_ isSelected: Bool, scaleFactor: CGFloat) -> some View {
        modifier(SelectedEffect(isSelected, scaleFactor: scaleFactor))
    }
}
