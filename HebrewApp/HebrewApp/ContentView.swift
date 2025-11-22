import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var animateGradient = false
    
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
                        Text("\(viewModel.scoreCorrect)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Miss")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(viewModel.scoreWrong)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .padding(.horizontal)
                
                Spacer()
                
                // Game Content
                if let exercise = viewModel.currentExercise {
                    switch exercise {
                    case .englishToHebrew(let question, let options):
                        MultipleChoiceView(
                            question: question.english,
                            options: options,
                            onOptionSelected: { viewModel.checkAnswer($0) },
                            isHebrewQuestion: false,
                            viewModel: viewModel
                        )
                    case .hebrewToEnglish(let question, let options):
                        MultipleChoiceView(
                            question: question.hebrew,
                            options: options,
                            onOptionSelected: { viewModel.checkAnswer($0) },
                            isHebrewQuestion: true,
                            viewModel: viewModel
                        )
                    case .phraseOrder(let phrase, let shuffledWords):
                        PhraseBuilderView(
                            hint: phrase.english,
                            currentWords: shuffledWords,
                            onCheck: { viewModel.checkAnswer($0) },
                            viewModel: viewModel
                        )
                        .id(phrase.id) // Force rebuild when phrase changes
                    case .typingPractice(let question, let isHebrewToEnglish):
                        TypingExerciseView(
                            prompt: isHebrewToEnglish ? question.hebrew : question.english,
                            isHebrewToEnglish: isHebrewToEnglish,
                            onSubmit: { viewModel.checkAnswer($0) },
                            viewModel: viewModel
                        )
                        .id(question.id)
                    case .prepositionPractice(let sentence, let options):
                        PrepositionExerciseView(
                            sentence: sentence,
                            options: options,
                            onOptionSelected: { viewModel.checkAnswer($0) },
                            viewModel: viewModel
                        )
                        .id(sentence.id)
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
