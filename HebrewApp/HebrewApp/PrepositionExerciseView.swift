import SwiftUI

struct PrepositionExerciseView: View {
    let sentence: PrepositionSentence
    let options: [String]
    let onOptionSelected: (String) -> Void
    @ObservedObject var viewModel: GameViewModel
    
    @State private var selectedPreposition: String?
    
    var body: some View {
        VStack(spacing: 40) {
            // Category badge
            Text(sentence.category)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
            
            // English hint
            Text(sentence.english)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Hebrew sentence with blank
            Text(sentence.hebrew)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .environment(\.layoutDirection, .rightToLeft)
            
            Spacer()
            
            // Options grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(options, id: \.self) { option in
                    let isSelected = viewModel.showFeedback && selectedPreposition == option
                    let isCorrect = option == sentence.correctPreposition
                    let feedbackColor = isSelected ? (isCorrect ? Color.green : Color.red) : Color.clear
                    
                    Button(action: {
                        selectedPreposition = option
                        onOptionSelected(option)
                    }) {
                        Text(option)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(
                                ZStack {
                                    Color.white.opacity(0.15)
                                        .background(.ultraThinMaterial)
                                    
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
                    .disabled(viewModel.showFeedback)
                }
            }
            .padding()
            
            Spacer()
        }
        .onChange(of: viewModel.currentExercise) { _ in
            selectedPreposition = nil
        }
    }
}
