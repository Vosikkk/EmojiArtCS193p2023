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
    var isGestureActive: Bool
    
    init(_ isSelected: Bool, _ scaleFactor: CGFloat, isGestureActive: Bool) {
        self.isSelected = isSelected
        self.scaleFactor = scaleFactor
        self.isGestureActive = isGestureActive
    }
    
    
    
    func body(content: Content) -> some View {
        content
            .overlay(isSelected && !isGestureActive ? ractangle : nil)
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
    func selectedEffect(_ isSelected: Bool, _ scaleFactor: CGFloat, isGestureActive: Bool) -> some View {
        modifier(SelectedEffect(isSelected, scaleFactor, isGestureActive: isGestureActive))
    }
}
