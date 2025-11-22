import SwiftUI

struct HardEnglishExerciseView: View {
    @ObservedObject var controller: HardEnglishGameController
    
    var body: some View {
        VStack(spacing: 20) {
            if let exercise = controller.currentExercise {
                switch exercise {
                case .definitionToWord(let question, let options):
                    renderQuestion(
                        title: "What word matches this definition?",
                        content: question.definition,
                        options: options,
                        display: { $0.word }
                    )
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func renderQuestion<T: Identifiable>(title: String, content: String, options: [T], display: @escaping (T) -> String) -> some View where T: Equatable, T.ID == String {
        VStack(spacing: 30) {
            // Question Header
            VStack(spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(content)
                    .font(.system(size: 24, weight: .bold)) // Smaller font for longer definitions
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding()
            }
            .padding()
            
            // 10 Options Grid (2 columns x 5 rows)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(options) { option in
                    let isSelected = controller.showFeedback && controller.selectedAnswerId == option.id
                    let feedbackColor = isSelected ? (controller.isCorrectAnswer ? Color.green : Color.red) : Color.clear
                    
                    Button(action: {
                        controller.checkAnswer(option)
                    }) {
                        Text(display(option))
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
                    .disabled(controller.showFeedback)
                }
            }
        }
    }
}
