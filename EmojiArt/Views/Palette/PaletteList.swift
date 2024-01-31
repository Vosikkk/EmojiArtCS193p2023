//
//  PaletteList.swift
//  EmojiArt
//
//  Created by Саша Восколович on 31.01.2024.
//

import SwiftUI

struct PaletteList: View {
    
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        NavigationStack {
            List(store.palettes) { palette in
                NavigationLink(value: palette) {
                    Text(palette.name)
                }
            }
            .navigationDestination(for: Palette.self) { palette in
                PaletteView(palette: palette)
            }
            .navigationTitle("\(store.name) Palettes")
        }
    }
}

#Preview {
    PaletteList()
}
