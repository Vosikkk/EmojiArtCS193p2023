//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Саша Восколович on 22.01.2024.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    
    @StateObject var defaultDocument = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(named: "Main")
   
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
                .environmentObject(paletteStore)
        }
    }
}
