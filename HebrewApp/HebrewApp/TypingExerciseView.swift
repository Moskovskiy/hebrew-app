import SwiftUI

struct TypingExerciseView: View {
    let prompt: String
    let isHebrewToEnglish: Bool
    let onSubmit: (String) -> Void
    @ObservedObject var viewModel: GameViewModel
    
    @State private var userInput: String = ""
    @FocusState private var isInputFocused: Bool
    
    var correctAnswer: String {
        // Extract correct answer from current exercise
        if case .typingPractice(let question, let isHebrewToEnglish) = viewModel.currentExercise {
            return isHebrewToEnglish ? question.english : question.hebrew
        }
        return ""
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // Prompt
            Text(prompt)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .multilineTextAlignment(.center)
                .shadow(radius: 5)
            
            Spacer()
            
            // Show correct answer if failed 3 times
            if viewModel.showCorrectAnswer {
                correctAnswerView
            } else {
                inputSection
            }
            
            Spacer()
        }
        .onAppear {
            isInputFocused = true
        }
        .onChange(of: viewModel.currentExercise) { _ in
            userInput = ""
            isInputFocused = true
        }
        .onChange(of: viewModel.isCorrectAnswer) { isCorrect in
            if isCorrect {
                userInput = ""
            }
        }
    }
    
    // MARK: - Subviews
    
    private var correctAnswerView: some View {
        VStack(spacing: 20) {
            Text("Correct Answer:")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            Text(correctAnswer)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.green)
                .padding(20)
                .background(
                    Color.white.opacity(0.15)
                        .background(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green.opacity(0.6), lineWidth: 2)
                )
                .cornerRadius(20)
                .shadow(color: Color.green.opacity(0.5), radius: 20, x: 0, y: 5)
        }
        .padding()
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
            // Text Input Field - Always RTL
            TextField("Type here...", text: $userInput)
                .font(.title)
                .foregroundColor(.white)
                .padding(20)
                .background(
                    Color.white.opacity(0.15)
                        .background(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(borderColor, lineWidth: viewModel.feedbackMessage != nil ? 3 : 2)
                )
                .cornerRadius(20)
                .shadow(color: shadowColor, radius: viewModel.feedbackMessage != nil ? 20 : 5, x: 0, y: 5)
                .multilineTextAlignment(.trailing)
                .environment(\.layoutDirection, .rightToLeft) // Always RTL
                .focused($isInputFocused)
                .disabled(viewModel.feedbackMessage != nil)
                .onSubmit {
                    if !userInput.isEmpty {
                        onSubmit(userInput)
                    }
                }
                .padding(.horizontal)
            
            // Feedback Message Display
            if let message = viewModel.feedbackMessage {
                Text(message)
                    .font(.headline)
                    .foregroundColor(feedbackTextColor)
                    .padding(.top, 8)
                    .transition(.opacity)
            }
            
            // Attempt counter
            if viewModel.typingAttempts > 0 && viewModel.feedbackMessage == nil {
                Text("Attempt \(viewModel.typingAttempts) of 3")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 8)
            }
            
            // Submit Button
            Button(action: {
                if !userInput.isEmpty {
                    onSubmit(userInput)
                }
            }) {
                Text("Check Answer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.white.opacity(0.15)
                            .background(.ultraThinMaterial)
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
            }
            .disabled(userInput.isEmpty || viewModel.feedbackMessage != nil)
            .opacity(userInput.isEmpty ? 0.5 : 1)
            .padding(.horizontal)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Computed Properties for Styling
    
    private var borderColor: Color {
        if viewModel.feedbackMessage != nil {
            if viewModel.isCorrectAnswer {
                return viewModel.isCloseMatch ? Color.orange : Color.green
            } else {
                return Color.red
            }
        } else {
            return Color.white.opacity(0.4)
        }
    }
    
    private var shadowColor: Color {
        if viewModel.feedbackMessage != nil {
            if viewModel.isCorrectAnswer {
                return viewModel.isCloseMatch ? Color.orange.opacity(0.6) : Color.green.opacity(0.6)
            } else {
                return Color.red.opacity(0.6)
            }
        } else {
            return Color.black.opacity(0.2)
        }
    }
    
    private var feedbackTextColor: Color {
        if viewModel.isCorrectAnswer {
            return viewModel.isCloseMatch ? .orange : .green
        } else {
            return .red
        }
    }
}
