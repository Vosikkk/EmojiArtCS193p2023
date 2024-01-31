//
//  EditablePaletteList.swift
//  EmojiArt
//
//  Created by Саша Восколович on 31.01.2024.
//

import SwiftUI

struct EditablePaletteList: View {
    
    @ObservedObject var store: PaletteStore
    
    @State private var showCursorPalette = false
    
    var body: some View {
        List {
            ForEach(store.palettes) { palette in
                NavigationLink(value: palette.id) {
                    VStack(alignment: .leading) {
                        Text(palette.name)
                        Text(palette.emojis).lineLimit(1)
                    }
                }
            }
            .onDelete { indexSet in
                store.palettes.remove(atOffsets: indexSet)
            }
            .onMove { indexSet, newOffset in
                store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
            }
        }
        .navigationDestination(for: Palette.ID.self) { paletteId in
            if let index = store.palettes.firstIndex(where: { $0.id == paletteId }) {
                PaletteEditor(palette: $store.palettes[index])
            }
        }
        .navigationDestination(isPresented: $showCursorPalette) {
            PaletteEditor(palette: $store.palettes[store.cursorIndex])
        }
        .navigationTitle("\(store.name) Palettes")
        .toolbar {
            Button {
                store.insert(name: "", emojis: "")
                showCursorPalette = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

//#Preview {
//    EditablePaletteList()
//}
