//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Саша Восколович on 22.01.2024.
//

import Foundation


precedencegroup PlusXMinusY {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator +- : PlusXMinusY


struct EmojiArt {
    
    var background: URL?
    private(set) var emojis: [Emoji] = []
    private var uniqueEmojiId = 0
    
    
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, string: emoji, position: position, size: size))
    }
    
    
    subscript(_ emojiId: Emoji.ID) -> Emoji? {
        if let index = index(of: emojiId) {
            return emojis[index]
        } else {
            return nil
        }
    }

    subscript(_ emoji: Emoji) -> Emoji {
        get {
            if let index = index(of: emoji.id) {
                return emojis[index]
            } else {
                return emoji // should probably throw error
            }
        }
        set {
            if let index = index(of: emoji.id) {
                emojis[index] = newValue
            }
        }
    }
    
    
    mutating func remove(emojiWith id: Emoji.ID) {
        if let idForRemove = index(of: id) {
            emojis.remove(at: idForRemove)
        }
    }
    
    
    private func index(of emojiId: Emoji.ID) -> Int? {
        emojis.firstIndex(where: { $0.id == emojiId } )
    }
    
   
    
    struct Emoji: Identifiable {
        
        var id: Int
        let string: String
        var position: Position
        var size: Int
        
        struct Position {
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0)
        }
    }
}

