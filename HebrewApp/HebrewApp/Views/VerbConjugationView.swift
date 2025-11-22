import SwiftUI

struct VerbConjugationView: View {
    let fromForm: VerbForm
    let toForm: VerbForm
    let prompt: String
    let onSubmit: (String) -> Void
    @ObservedObject var controller: GameController

    @State private var userInput: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 30) {
            // Compact form transformation display
            HStack(spacing: 15) {
                VStack(spacing: 5) {
                    Text(fromForm.english)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text(fromForm.hebrew)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }

                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.5))

                VStack(spacing: 5) {
                    Text(toForm.english)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text("?")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
            .padding(.horizontal)

            // Example sentence with blank
            if let exampleSentence = toForm.exampleSentence {
                VStack(spacing: 8) {
                    Text("Complete the sentence:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    Text(exampleSentence)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .environment(\.layoutDirection, .rightToLeft)
                }
                .padding()
            }

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
            VStack(spacing: 15) {
                Text("Correct Answer:")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))

                // Show the verb form
                VStack(spacing: 8) {
                    Text(toForm.hebrew)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)

                    Text(toForm.pronunciation)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))

                    Text(toForm.english)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.6))
                }

                // Show the complete sentence with the word filled in
                if let exampleSentence = toForm.exampleSentence {
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical, 5)

                    VStack(spacing: 8) {
                        Text("Complete sentence:")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))

                        Text(exampleSentence.replacingOccurrences(of: "______", with: toForm.hebrew))
                            .font(.title3)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .environment(\.layoutDirection, .rightToLeft)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.3))
                            )
                    }
                }
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
                .multilineTextAlignment(.trailing)
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "he"))
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
