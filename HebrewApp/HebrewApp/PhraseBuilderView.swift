import SwiftUI
import UniformTypeIdentifiers

struct PhraseBuilderView: View {
    let hint: String
    let initialWords: [String]
    let onCheck: ([String]) -> Void
    @ObservedObject var viewModel: GameViewModel
    
    @State private var availableWords: [String]
    @State private var placedWords: [String] = []
    @State private var draggedWord: String?
    
    init(hint: String, currentWords: [String], onCheck: @escaping ([String]) -> Void, viewModel: GameViewModel) {
        self.hint = hint
        self.initialWords = currentWords
        self.onCheck = onCheck
        self.viewModel = viewModel
        self._availableWords = State(initialValue: currentWords)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Hint - Smaller font
            Text(hint)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .multilineTextAlignment(.center)
                .shadow(radius: 5)
            
            // Target Field (Sentence Construction) - RTL for Hebrew
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.2))
                    .frame(minHeight: 80) // Reduced from 100
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    )
                
                if placedWords.isEmpty {
                    Text("Drag words here")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.headline)
                }
                
                FlowLayout(items: placedWords) { word in
                    WordCard(text: word)
                        .onDrag {
                            self.draggedWord = word
                            return NSItemProvider(object: word as NSString)
                        }
                        .onTapGesture {
                            // Tap to return to bank
                            withAnimation {
                                if let index = placedWords.firstIndex(of: word) {
                                    placedWords.remove(at: index)
                                    availableWords.append(word)
                                }
                            }
                        }
                }
                .padding()
                .environment(\.layoutDirection, .rightToLeft) // RTL for Hebrew
            }
            .padding(.horizontal)
            .onDrop(of: [UTType.text], delegate: PhraseDropDelegate(destinationWords: $placedWords, sourceWords: $availableWords, draggedWord: $draggedWord))
            
            Spacer()
            
            // Source Bank (Available Words)
            FlowLayout(items: availableWords) { word in
                WordCard(text: word)
                    .onDrag {
                        self.draggedWord = word
                        return NSItemProvider(object: word as NSString)
                    }
                    .onTapGesture {
                        // Tap to move to field
                        withAnimation {
                            if let index = availableWords.firstIndex(of: word) {
                                availableWords.remove(at: index)
                                placedWords.append(word)
                            }
                        }
                    }
            }
            .padding()
            .frame(minHeight: 100)
            
            // Check Button with Feedback - Only show when at least one word is placed
            if !placedWords.isEmpty {
                Button(action: {
                    onCheck(placedWords)
                }) {
                    Text("Check Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                // Glass background
                                Color.white.opacity(0.1)
                                
                                // Feedback color overlay
                                if viewModel.feedbackMessage != nil {
                                    let feedbackColor = viewModel.isCorrectAnswer ? Color.green : Color.red
                                    feedbackColor.opacity(0.4)
                                }
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(20)
                        .shadow(
                            color: viewModel.feedbackMessage != nil 
                                ? (viewModel.isCorrectAnswer ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                                : Color.black.opacity(0.1),
                            radius: viewModel.feedbackMessage != nil ? 20 : 10,
                            x: 0,
                            y: 10
                        )
                }
                .disabled(viewModel.feedbackMessage != nil) // Disable during feedback
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

// Helper View for Word Chips
struct WordCard: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .glass()
            .foregroundColor(.white)
            .fixedSize(horizontal: true, vertical: false)
    }
}

// Simple Flow Layout using Layout Protocol (iOS 16+) or fallback
// Since we want to be safe, let's use a wrapping HStack approach with GeometryReader or just LazyVGrid with adaptive items
struct FlowLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 10)], spacing: 10) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

struct PhraseDropDelegate: DropDelegate {
    @Binding var destinationWords: [String]
    @Binding var sourceWords: [String]
    @Binding var draggedWord: String?
    
    func performDrop(info: DropInfo) -> Bool {
        guard let word = draggedWord else { return false }
        
        // If word is coming from source (not already in destination)
        if let sourceIndex = sourceWords.firstIndex(of: word) {
            withAnimation {
                sourceWords.remove(at: sourceIndex)
                destinationWords.append(word)
            }
            return true
        }
        
        // If word is already in destination (reordering) - simplified: just append to end if dropped on container
        // For true reorder, we need more complex logic, but "Bank -> Field" is the primary interaction.
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Optional: Visual feedback
    }
}
