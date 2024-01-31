//
//  SnakeEffect.swift
//  EmojiArt
//
//  Created by Саша Восколович on 28.01.2024.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    
    var amount: CGFloat = 10
    var shakePerUnit: Int = 3
    var animatableData: CGFloat
    var isEnabled: Bool = true
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        if isEnabled {
           return ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakePerUnit)), y: 0))
        } else {
             return ProjectionTransform(CGAffineTransform.identity)
        }
    }
    
}


extension View {
    func shakeEffect(with force: CGFloat, isEnabled: Bool) -> some View {
        modifier(ShakeEffect(animatableData: force, isEnabled: isEnabled))
    }
}

extension Animation {
    static func spin(duration: TimeInterval) -> Animation {
        .linear(duration: duration).repeatForever(autoreverses: false)
    }
}
