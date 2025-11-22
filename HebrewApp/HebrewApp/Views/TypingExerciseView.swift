import SwiftUI

struct TypingExerciseView: View {
    let prompt: String
    let questionWord: Word? // Optional word object for hints
    let isHebrewToEnglish: Bool
    let onSubmit: (String) -> Void
    @ObservedObject var controller: GameController
    
    @State private var userInput: String = ""
    @FocusState private var isInputFocused: Bool
    
    var correctAnswer: String {
        // Extract correct answer from current exercise
        switch controller.currentExercise {
        case .typingPractice(let question, let isHebrewToEnglish):
            return isHebrewToEnglish ? question.english : question.hebrew
        case .phraseTyping(let phrase):
            return phrase.hebrew
        default:
            return ""
        }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // Prompt
            VStack(spacing: 10) {
                Text(prompt)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(radius: 5)
                
                if let word = questionWord {
                    WordHintView(word: word)
                }
            }
            .padding()
            
            Spacer()
            
            // Show correct answer if failed 3 times
            if controller.showCorrectAnswer {
                correctAnswerView
            } else {
                inputSection
            }
            
            Spacer()
        }
        .onAppear {
            isInputFocused = true
        }
        .onChange(of: controller.currentExercise) { _ in
            userInput = ""
            isInputFocused = true
        }
        .onChange(of: controller.isCorrectAnswer) { isCorrect in
            if isCorrect {
                userInput = ""
            }
        }
    }
    
    // MARK: - Subviews
    
    private var correctAnswerView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Correct Answer:")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(correctAnswer)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: {
                controller.nextExercise()
            }) {
                Text("Got it")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .shadow(radius: 5)
            }
        }
        .padding()
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
            // Text Input Field
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
                        .stroke(borderColor, lineWidth: controller.feedbackMessage != nil ? 3 : 2)
                )
                .cornerRadius(20)
                .shadow(color: shadowColor, radius: controller.feedbackMessage != nil ? 20 : 5, x: 0, y: 5)
                .multilineTextAlignment(isHebrewToEnglish ? .leading : .trailing)
                .environment(\.layoutDirection, isHebrewToEnglish ? .leftToRight : .rightToLeft)
                .environment(\.locale, Locale(identifier: isHebrewToEnglish ? "en" : "he"))
                .focused($isInputFocused)
                .disabled(controller.feedbackMessage != nil)
                .onSubmit {
                    if !userInput.isEmpty {
                        onSubmit(userInput)
                    }
                }
                .padding(.horizontal)
            
            // Feedback Message Display
            if let message = controller.feedbackMessage {
                Text(message)
                    .font(.headline)
                    .foregroundColor(feedbackTextColor)
                    .padding(.top, 8)
                    .transition(.opacity)
            }
            
            // Attempt counter
            if controller.typingAttempts > 0 && controller.feedbackMessage == nil {
                Text("Attempt \(controller.typingAttempts) of 3")
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
            .disabled(userInput.isEmpty || controller.feedbackMessage != nil)
            .opacity(userInput.isEmpty ? 0.5 : 1)
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Give Up Button
            Button(action: {
                controller.giveUp()
            }) {
                Text("Give Up")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
            }
            .disabled(controller.feedbackMessage != nil)
            .opacity(controller.feedbackMessage != nil ? 0 : 1)
        }
    }
    
    // MARK: - Computed Properties for Styling
    
    private var borderColor: Color {
        if controller.feedbackMessage != nil {
            if controller.isCorrectAnswer {
                return controller.isCloseMatch ? Color.orange : Color.green
            } else {
                return Color.red
            }
        } else {
            return Color.white.opacity(0.4)
        }
    }
    
    private var shadowColor: Color {
        if controller.feedbackMessage != nil {
            if controller.isCorrectAnswer {
                return controller.isCloseMatch ? Color.orange.opacity(0.6) : Color.green.opacity(0.6)
            } else {
                return Color.red.opacity(0.6)
            }
        } else {
            return Color.black.opacity(0.2)
        }
    }
    
    private var feedbackTextColor: Color {
        if controller.isCorrectAnswer {
            return controller.isCloseMatch ? .orange : .green
        } else {
            return .red
        }
    }
}
