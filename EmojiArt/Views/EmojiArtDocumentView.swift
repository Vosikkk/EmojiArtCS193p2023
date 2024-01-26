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
        
        var body: some View {
            VStack(spacing: 0) {
                documentBody
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
                        .scaleEffect(selectedEmojis.isEmpty ? scaleFactor : lastBackgoundZoom)
                        .offset(panOffset)
                }
                .gesture(panGesture.simultaneously(with: zoomGesture).simultaneously(with: tapDocumentGesture).simultaneously(with: isLongTappingEnd ? nil : longTappingGesture))
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
                    .gesture(handleEmojiTap(on: emoji)
                        .simultaneously(with: isSelected(emoji.id) ? emojiPanGesture : nil)
                        .simultaneously(with: isSelected(emoji.id) ? zoomGesture : nil)
                    )
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
        
        @State private var isLongTappingEnd: Bool = false
        @State private var lastBackgoundZoom: CGFloat = 1
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
                    if selectedEmojis.isEmpty {
                        zoom *= endingPinchScale
                        lastBackgoundZoom = zoom
                    } else {
                        for id in selectedEmojis {
                            document.resize(emojiWith: id, by: endingPinchScale)
                        }
                    }
                }
        }
        
        private var panGesture: some Gesture {
            DragGesture()
                .updating($gesturePan) { value, gesturePan, _ in
                    gesturePan = value.translation
                }
                .onEnded { value in
                    if selectedEmojis.isEmpty {
                        pan += value.translation
                    }
                }
        }
        
        private var tapDocumentGesture: some Gesture {
            TapGesture()
                .onEnded {
                    withAnimation {
                        selectedEmojis.removeAll()
                    }
                }
        }
      
       
        @GestureState private var emojiGestureZoom: CGFloat = 1
        @GestureState private var emojiGesturePan: CGOffset = .zero
        
        private var emojiPanGesture: some Gesture {
            DragGesture()
                .updating($emojiGesturePan) { value, gesturePan, _ in
                    gesturePan = value.translation
                }
                .onEnded { value in
                    for id in selectedEmojis {
                        document.move(emojiWith: id, by: value.translation)
                    }
                }
        }
        
        private func handleEmojiTap(on emoji: Emoji) -> some Gesture {
            TapGesture()
                .onEnded {
                    if isSelected(emoji.id) {
                        selectedEmojis.remove(emoji.id)
                    } else {
                        selectedEmojis.insert(emoji.id)
                    }
                }
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
                .selectedEffect(isSelected(emoji.id), scaleFactor, isGestureActive: isMotion)
                .offset(shouldApplyOffset(isSelected(emoji.id)))
                .scaleEffect(shouldApplyEmojiScale(isSelected(emoji.id)))
                .position(emoji.position.in(geometry))
                .overlay(isLongTappingEnd ? deleter(for: emoji, in: emoji.position.in(geometry)) : nil)
        }
        
        private var longTappingGesture: some Gesture {
            LongPressGesture(minimumDuration: 1.0)
                .onEnded { finish in
                    isLongTappingEnd = finish
                }
        }
        
        @State private var selectedEmojis: Set<Emoji.ID> = []
        
        private var scaleFactor: CGFloat {
            zoom * gestureZoom
        }
        
        private var isMotion: Bool {
            emojiGesturePan != .zero
        }
        
        private var panOffset: CGOffset {
            pan + gesturePan
        }
       
        private func isSelected(_ id: Emoji.ID) -> Bool {
            selectedEmojis.contains(id)
        }
        
        private func shouldApplyOffset(_ isSelected: Bool) -> CGOffset {
             isSelected ? emojiGesturePan : .zero
        }
        
        private func shouldApplyEmojiScale(_ isSelected: Bool) -> CGFloat {
             isSelected ? gestureZoom : 1
        }
        
        private func deleter(for emoji: Emoji, in position: CGPoint) -> some View {
            return AnimatedActionButton(systemImage: "minus.circle") {
                document.remove(emojiWith: emoji.id)
                isLongTappingEnd = false
            }
            .offset(shouldApplyOffset(true))
            .position(CGPoint(x: position.x + CGFloat(emoji.size / 2), y: position.y - CGFloat(emoji.size / 2)))
            
        }
        
    }


    #Preview {
        EmojiArtDocumentView(document: EmojiArtDocument())
            .environmentObject(PaletteStore(named: "Preview"))
    }
