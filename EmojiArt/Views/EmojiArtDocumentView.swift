//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Саша Восколович on 22.01.2024.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    typealias Emoji = EmojiArt.Emoji
    private let paletteEmojiSize: CGFloat = 40
    
    @ObservedObject var document: EmojiArtDocument
    
   
    
   
    @GestureState private var emojiGestureZoom: CGFloat = 1
    @GestureState private var emojiGesturePan: CGOffset = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
                .gesture(tapDocumentGesture)
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: SturlData.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background)
            .position(Emoji.Position.zero.in(geometry))
        ForEach(document.emojis) { emoji in
            view(for: emoji, in: geometry)
                .gesture(handleTap(on: emoji))
            
        }
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            .onEnded { endingPinchScale in
                zoom *= endingPinchScale
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { value, gesturePan, _ in
                gesturePan = value.translation
            }
            .onEnded { value in
                pan += value.translation
            }
    }
    
    private func drop(_ sturldatas: [SturlData], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji, at: emojiPosition(at: location, in: geometry), size: paletteEmojiSize / zoom)
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
    
    private func view(for emoji: Emoji, in geometry: GeometryProxy) -> some View {
        Text(emoji.string)
            .font(emoji.font)
            .selectEffect(isSelected: isAlreadySelected(emoji.id), scaledTo: zoom * gestureZoom)
            .position(emoji.position.in(geometry))
    }
    
    
    @State private var selectedEmojis: Set<Emoji.ID> = []
    
    
    private var tapDocumentGesture: some Gesture {
        TapGesture()
            .onEnded {
                selectedEmojis.removeAll()
            }
    }
  
    private func handleTap(on emoji: Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                if isAlreadySelected(emoji.id) {
                    selectedEmojis.remove(emoji.id)
                } else {
                    selectedEmojis.insert(emoji.id)
                }
            }
    }
    
    
    
    
    private func isAlreadySelected(_ id: Emoji.ID) -> Bool {
        selectedEmojis.contains(id)
    }
    
}


#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
