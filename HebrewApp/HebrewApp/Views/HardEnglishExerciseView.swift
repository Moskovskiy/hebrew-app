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
    private func renderQuestion<T: Identifiable>(title: String, content: String, options: [T], display: @escaping (T) -> String) -> some View where T: Equatable {
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
                    Button(action: {
                        controller.checkAnswer(option)
                    }) {
                        Text(display(option))
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                Color.white.opacity(0.15)
                                    .background(.ultraThinMaterial)
                            )
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .disabled(controller.showFeedback)
                }
            }
        }
    }
}
