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
    
    
    @State private var isNeedToShowButtonForDelete: Bool = false
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    
    
    @State private var unselectedEmoji: Emoji.ID = -1
    
    @GestureState private var emojiGestureZoom: CGFloat = 1
    @GestureState private var emojiGesturePan: CGOffset = .zero
    @GestureState private var unselectedEmojiPan: CGOffset = .zero
    
    
    @State private var shouldWobble = false
    
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
                    .scaleEffect(scaleDocumentEffect)
                    .offset(panDocumentOffset)
            }
            .gesture(longTappingGesture.simultaneously(with: !isNeedToShowButtonForDelete ? zoomGesture : nil).simultaneously(with: tapDocumentGesture).simultaneously(with:  !isNeedToShowButtonForDelete ? panGesture : nil))
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
                    .simultaneously(with: !isNeedToShowButtonForDelete ? emojiPanGesture(on: emoji.id) : nil)
                    .simultaneously(with: isSelectedEmoji(by: emoji.id) ? zoomGesture : nil)
                )
        }
    }
    
    private func view(for emoji: Emoji, in geometry: GeometryProxy) -> some View {
        Text(emoji.string)
            .font(emoji.font)
            .selectedEffect(isSelectedEmoji(by: emoji.id), scaleDocumentEffect, isGestureActive: selectedEmojiInMotion)
            .offset(calculateEmojiOffset(dependingOn: isSelectedEmoji(by: emoji.id), for: emoji.id))
            .scaleEffect(shouldApplyEmojiScale(isSelectedEmoji(by: emoji.id)))
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
        .position(positionForButton(relativelyTo: emoji, in: position))
        .zIndex(1)
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
                isNeedToShowButtonForDelete = false
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
    
    private var scaleDocumentEffect: CGFloat {
        selectedEmojis.isEmpty ? zoom * gestureZoom : zoom
    }
    
    private var selectedEmojiInMotion: Bool {
        emojiGesturePan != .zero
    }
    
    private var panDocumentOffset: CGOffset {
        selectedEmojis.isEmpty ? pan + gesturePan : pan
    }
    
    private func isSelectedEmoji(by id: Emoji.ID) -> Bool {
        selectedEmojis.contains(id)
    }
    
    private func calculateEmojiOffset(dependingOn selection: Bool, for emojiId: Emoji.ID) -> CGOffset {
        selection ? emojiGesturePan : unselectedEmoji == emojiId ? unselectedEmojiPan : .zero
    }
    
    private func shouldApplyEmojiScale(_ isSelected: Bool) -> CGFloat {
        isSelected ? gestureZoom : 1
    }
}


// MARK: - Document Gesture

extension EmojiArtDocumentView {
    
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
                // Pan for background doesn't update
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
    
    private var longTappingGesture: some Gesture {
        LongPressGesture(minimumDuration: 1.0)
            .onEnded { finished in
                isNeedToShowButtonForDelete = finished
            }
    }
}


// MARK: - Emoji Gesture

extension EmojiArtDocumentView {
    
    private func emojiPanGesture(on emojiId: Emoji.ID) -> some Gesture {
        DragGesture()
            .updating(isSelectedEmoji(by: emojiId) ? $emojiGesturePan : $unselectedEmojiPan) { value, gesturePan, _ in
                // Update the translation based on whether the dragged emoji is selected or unselected.
                // The binding is changed accordingly to $emojiGesturePan for selected emojis
                // and $unselectedEmojiPan for unselected emojis.
                // Also Extra
                gesturePan = value.translation
            }
            .onEnded { value in
                if !isSelectedEmoji(by: emojiId) {
                    document.move(emojiWith: emojiId, by: value.translation)
                } else {
                    for id in selectedEmojis {
                        document.move(emojiWith: id, by: value.translation)
                    }
                }
            }
            .onChanged { _ in
                // Extra task
                // Here we want to determine dragging of unselected emoji
                if !isSelectedEmoji(by: emojiId) && unselectedEmoji != emojiId {
                    unselectedEmoji = emojiId
                }
            }
    }
    
    private func handleEmojiTap(on emoji: Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                if isSelectedEmoji(by: emoji.id) {
                    selectedEmojis.remove(emoji.id)
                } else {
                    selectedEmojis.insert(emoji.id)
                }
            }
    }
}


#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
