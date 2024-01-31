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
    
    
    // MARK: - Views
    
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
                    .scaleEffect(scaleEffect)
                    .offset(panOffset)
            }
            .gesture(panGesture.simultaneously(with: !isNeedToShowButtonForDelete ? zoomGesture : nil).simultaneously(with: tapDocumentGesture).simultaneously(with: longTappingGesture))
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
                    .simultaneously(with: allowPan(for: emoji.id) ? emojiPanGesture : nil)
                    .simultaneously(with: isSelected(emoji.id) ? zoomGesture : nil)
                )
        }
    }
    
    private func view(for emoji: Emoji, in geometry: GeometryProxy) -> some View {
        Text(emoji.string)
            .font(emoji.font)
            .selectedEffect(isSelected(emoji.id), scaleEffect, isGestureActive: isMotion)
            .offset(shouldApplyOffset(isSelected(emoji.id)))
            .scaleEffect(shouldApplyEmojiScale(isSelected(emoji.id)))
            .position(emoji.position.in(geometry))
            .overlay(isNeedToShowButtonForDelete ? deleter(for: emoji, in: emoji.position.in(geometry)) : nil)
    }
    
    private func deleter(for emoji: Emoji, in position: CGPoint) -> some View {
        return AnimatedActionButton(systemImage: "x.circle.fill") {
            document.remove(emojiWith: emoji.id)
            if selectedEmojis.contains(emoji.id) {
                selectedEmojis.remove(emoji.id)
            }
        }
        .foregroundStyle(.gray)
        .font(emoji.halfFont)
        .position(positionForButton(by: emoji, in: position))
        .zIndex(1)
    }
    
    // MARK: - Document Gesture
    
    @State private var isNeedToShowButtonForDelete: Bool = false
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
                    // so turn off deleting condition
                    isNeedToShowButtonForDelete = false
                }
            }
    }
    
    
    // MARK: - Emoji Gesture
    
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
                // select/diselect
                if isSelected(emoji.id) {
                    selectedEmojis.remove(emoji.id)
                } else {
                    selectedEmojis.insert(emoji.id)
                }
            }
    }
    
    
    private var longTappingGesture: some Gesture {
        LongPressGesture(minimumDuration: 1.0)
            .onEnded { finished in
                isNeedToShowButtonForDelete = finished
            }
    }
    
    
    // MARK: - Helpers
    
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
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
    
    
    @State private var selectedEmojis: Set<Emoji.ID> = []
    
    private var scaleEffect: CGFloat {
        selectedEmojis.isEmpty ? zoom * gestureZoom : zoom
    }
    
    private var isMotion: Bool {
        emojiGesturePan != .zero
    }
    
    private var panOffset: CGOffset {
        selectedEmojis.isEmpty ? pan + gesturePan : pan
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
    
    private func allowPan(for emojiId: Emoji.ID ) -> Bool {
        isSelected(emojiId) && !isNeedToShowButtonForDelete
    }
}


    #Preview {
        EmojiArtDocumentView(document: EmojiArtDocument())
            .environmentObject(PaletteStore(named: "Preview"))
    }
