import SwiftUI

struct ArabicExerciseView: View {
    @ObservedObject var controller: ArabicGameController
    @State private var animateGradient = false
    @State private var selectedOption: Any?

    var body: some View {
        ZStack {
            // Animated Background - Very Dark
            LinearGradient(colors: [Color(red: 0.02, green: 0.02, blue: 0.1),
                                   Color(red: 0.05, green: 0.05, blue: 0.15),
                                   Color(red: 0.0, green: 0.0, blue: 0.08)],
                          startPoint: animateGradient ? .topLeading : .bottomLeading,
                          endPoint: animateGradient ? .bottomTrailing : .topTrailing)
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }

            // Floating Circles
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 200, height: 200)
                .offset(x: -100, y: -200)
                .blur(radius: 10)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 300)
                .blur(radius: 20)

            VStack {
                // Score Header - No Background
                HStack {
                    VStack(alignment: .leading) {
                        Text("Success")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(controller.scoreCorrect)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Miss")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(controller.scoreWrong)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .padding(.horizontal)

                Spacer()

                // Game Content
                if let exercise = controller.currentExercise {
                    switch exercise {
                    case .letterToSound(let question, let options):
                        renderQuestion(
                            title: "What sound is this?",
                            content: question.forms.start,
                            options: options,
                            display: { $0.sound },
                            getId: { $0.id }
                        )
                    case .wordToEnglish(let question, let options):
                        renderQuestion(
                            title: "How do you say this?",
                            content: question.arabic,
                            options: options,
                            display: { $0.pronunciation },
                            secondaryDisplay: { $0.english },
                            getId: { $0.id }
                        )
                    }
                }

                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func renderQuestion<T: Identifiable & Equatable>(title: String, content: String, options: [T], display: @escaping (T) -> String, secondaryDisplay: ((T) -> String)? = nil, getId: @escaping (T) -> String) -> some View {
        VStack(spacing: 30) {
            // Question Header
            VStack(spacing: 10) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))

                Text(content)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
            }
            .padding()

            // 10 Options Grid (2 columns x 5 rows)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(options) { option in
                    let isSelected = controller.showFeedback && isOptionSelected(option, getId: getId)
                    let feedbackColor = isSelected ? (controller.isCorrectAnswer ? Color.green : Color.red) : Color.clear

                    Button(action: {
                        selectedOption = option as Any
                        controller.checkAnswer(option)
                    }) {
                        VStack(spacing: 4) {
                            Text(display(option))
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)

                            if let secondary = secondaryDisplay {
                                Text(secondary(option))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
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
            .padding()
        }
    }

    private func isOptionSelected<T: Identifiable>(_ option: T, getId: (T) -> String) -> Bool {
        guard let selected = selectedOption else { return false }
        if let selectedTyped = selected as? T {
            return getId(selectedTyped) == getId(option)
        }
        return false
    }
}
