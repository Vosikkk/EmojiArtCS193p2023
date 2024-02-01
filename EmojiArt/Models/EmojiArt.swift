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


struct EmojiArt: Codable {
    
    var background: URL?
    private(set) var emojis: [Emoji] = []
    private var uniqueEmojiId = 0
    
    
    func json() throws -> Data {
        do {
            let encoded = try JSONEncoder().encode(self)
            print("EmojiArt = \(String(data: encoded, encoding: .utf8) ?? "nil")")
            return encoded
        } catch {
            throw EmojiArtErrors.encode(error.localizedDescription)
        }
    }
    
  
    
    
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
    
   
    
    struct Emoji: Identifiable, Codable {
        
        var id: Int
        let string: String
        var position: Position
        var size: Int
        
        struct Position: Codable {
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0)
        }
    }
    
    enum EmojiArtErrors: LocalizedError {
        
        case decode(String)
        case encode(String)
        
        var errorDescription: String? {
            switch self {
            case .decode(let description):
                return NSLocalizedString("Decoding error: \(description)", comment: "Description for decoding")
            case .encode(let description):
                return NSLocalizedString("Encoding error: \(description)", comment: "Description for encoding")
            }
        }
    }
}

extension EmojiArt {
    
    init(json: Data) throws {
        do {
            self = try JSONDecoder().decode(EmojiArt.self, from: json)
        } catch {
             print(EmojiArtErrors.decode(error.localizedDescription))
        }
    }
}
