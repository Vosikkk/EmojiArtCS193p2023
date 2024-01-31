//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Саша Восколович on 31.01.2024.
//

import SwiftUI

struct PaletteEditor: View {
    
    @Binding var palette: Palette
    
    @FocusState private var focused: Focused?
    
    @State private var emojisToAdd: String = ""
    
    private let emojiFont = Font.system(size: 40)
    
    enum Focused {
        case name
        case addEmojis
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $palette.name)
                    .focused($focused, equals: .name)
            } header: {
                Text("Name")
            }
            Section {
                TextField("Add Emojis Here", text: $emojisToAdd)
                    .focused($focused, equals: .addEmojis)
                    .font(emojiFont)
                    .onChange(of: emojisToAdd) { oldValue, newValue in
                        palette.emojis = (newValue + palette.emojis)
                            .filter { $0.isEmoji }
                            .uniqued
                    }
                removeEmojis
            } header: {
                Text("Emojis")
            }
        }
        .onAppear {
            if palette.name.isEmpty {
                focused = .name
            } else {
                focused = .addEmojis
            }
        }
    }
    
    
    var removeEmojis: some View {
        VStack(alignment: .trailing) {
            Text("Tap to Remove Emojis").font(.caption).foregroundStyle(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.remove(emoji.first!)
                                emojisToAdd.remove(emoji.first!)
                            }
                        }
                }
            }
        }
        .font(emojiFont)
    }
}

struct Preview: View {
    @State private var palette = PaletteStore(named: "Preview").palettes.first!
    
    var body: some View {
        PaletteEditor(palette: $palette)
    }
}

#Preview {
    Preview()
}
