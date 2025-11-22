import SwiftUI

struct MultipleChoiceView: View {
    let question: String
    let questionWord: Word? // Optional word object for hints
    let options: [Word]
    let onOptionSelected: (Word) -> Void
    let isHebrewQuestion: Bool
    @ObservedObject var controller: GameController
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                // Display question as pills if it contains semicolons
                if question.contains(";") {
                    VStack(spacing: 8) {
                        ForEach(question.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }, id: \.self) { item in
                            Text(item)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                )
                                .background(.ultraThinMaterial, in: Capsule())
                                .shadow(radius: 5)
                        }
                    }
                } else {
                    Text(question)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .shadow(radius: 5)
                }

                if let word = questionWord {
                    WordHintView(word: word)
                }
            }
            .padding()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(options) { option in
                    let isSelected = controller.showFeedback && controller.selectedWord?.id == option.id
                    let feedbackColor = isSelected ? (controller.isCorrectAnswer ? Color.green : Color.red) : Color.clear
                    
                    Button(action: {
                        onOptionSelected(option)
                    }) {
                        Text(isHebrewQuestion ? option.english : option.hebrew)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(
                                ZStack {
                                    // Enhanced Glass background with blur
                                    Color.white.opacity(0.15)
                                        .background(.ultraThinMaterial)
                                    
                                    // Feedback color overlay
                                    if isSelected {
                                        feedbackColor.opacity(0.5)
                                    }
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                            .shadow(
                                color: isSelected ? feedbackColor.opacity(0.9) : Color.white.opacity(0.1), 
                                radius: isSelected ? 25 : 15, 
                                x: 0, 
                                y: isSelected ? 10 : 5
                            )
                    }
                    .disabled(controller.showFeedback) // Disable buttons during feedback
                }
            }
            .padding()
        }
    }
}
