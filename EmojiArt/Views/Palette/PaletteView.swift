//
//  PaletteView.swift
//  EmojiArt
//
//  Created by Саша Восколович on 31.01.2024.
//

import SwiftUI

struct PaletteView: View {
    
    let palette: Palette
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: Constants.minEmojiSize))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    NavigationLink(value: emoji) {
                        Text(emoji)
                    }
                }
            }
            .navigationDestination(for: String.self) { emoji in
                Text(emoji).font(.system(size: Constants.emojiFontSize))
            }
            Spacer()
        }
        .padding()
        .font(.largeTitle)
        .navigationTitle(palette.name)
    }
    
    private struct Constants {
        static let emojiFontSize: CGFloat = 300
        static let minEmojiSize: CGFloat = 40
    }
}

//#Preview {
//    PaletteView()
//}
