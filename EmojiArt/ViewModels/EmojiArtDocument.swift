//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Саша Восколович on 22.01.2024.
//

import SwiftUI


class EmojiArtDocument: ObservableObject {
    
    
    typealias Emoji = EmojiArt.Emoji
    
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            autosave()
        }
    }
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaved.emojiart")
    
    
    private func autosave() {
        save(to: autosaveURL)
       // print("autosaved to \(autosaveURL)")
    }
    
    private func save(to url: URL) {
        do {
            let data = try emojiArt.json()
            try data.write(to: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }

    
    init() {
        if let data = try? Data(contentsOf: autosaveURL),
           let savedEmojiArt = try? EmojiArt(json: data) {
            emojiArt = savedEmojiArt
        }
    }
    
    
    // MARK: - Intent(s)
    
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }
    
   
    private func move(_ emoji: Emoji, by offset: CGOffset) {
        let exitingPosition = emojiArt[emoji].position
        emojiArt[emoji].position = exitingPosition +- offset
    }
    
    func move(emojiWith id: Emoji.ID, by offset: CGOffset) {
        if let emoji = emojiArt[id] {
            move(emoji, by: offset)
        }
    }
    
    private func resize(_ emoji: Emoji, by scale: CGFloat) {
        emojiArt[emoji].size = Int(CGFloat(emojiArt[emoji].size) * scale)
    }
    
    func resize(emojiWith id: Emoji.ID, by scale: CGFloat) {
        if let emoji = emojiArt[id] {
            resize(emoji, by: scale)
        }
    }
    
    func remove(emojiWith id: Emoji.ID) {
        emojiArt.remove(emojiWith: id)
    }
}



extension EmojiArt.Emoji {
    
    var font: Font {
        Font.system(size: CGFloat(size))
    }
    
    var halfFont: Font {
        Font.system(size: CGFloat(size / 2))
    }
}


extension EmojiArt.Emoji.Position {
    
    typealias Position = EmojiArt.Emoji.Position
    
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
    
    static func +-(lhs: Position, rhs: CGOffset) -> Position {
       Position(x: lhs.x + Int(rhs.width), y: lhs.y - Int(rhs.height))
    }
}

extension View {
    
    func positionForButton(relativelyTo emoji: EmojiArt.Emoji, in position: CGPoint) -> CGPoint {
         CGPoint(x: position.x - CGFloat(Double(emoji.size) / 2), y: position.y - CGFloat(Double(emoji.size) / 1.4))
    }
}
