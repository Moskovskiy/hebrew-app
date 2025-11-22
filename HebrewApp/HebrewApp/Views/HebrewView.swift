import SwiftUI

struct HebrewView: View {
    @StateObject private var controller = GameController()
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated Background - Blue for Hebrew theme
            LinearGradient(colors: [Color(red: 0.0, green: 0.1, blue: 0.4), 
                                   Color(red: 0.0, green: 0.2, blue: 0.5), 
                                   Color(red: 0.0, green: 0.05, blue: 0.3)], 
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
                    case .englishToHebrew(let question, let options):
                        MultipleChoiceView(
                            question: question.english,
                            questionWord: question,
                            options: options,
                            onOptionSelected: { controller.checkAnswer($0) },
                            isHebrewQuestion: false,
                            controller: controller
                        )
                    case .hebrewToEnglish(let question, let options):
                        MultipleChoiceView(
                            question: question.hebrew,
                            questionWord: question,
                            options: options,
                            onOptionSelected: { controller.checkAnswer($0) },
                            isHebrewQuestion: true,
                            controller: controller
                        )
                    case .phraseOrder(let phrase, let shuffledWords):
                        PhraseBuilderView(
                            hint: phrase.english,
                            phrase: phrase,
                            currentWords: shuffledWords,
                            onCheck: { controller.checkAnswer($0) },
                            controller: controller
                        )
                        .id(phrase.id) // Force rebuild when phrase changes
                    case .typingPractice(let question, let isHebrewToEnglish):
                        TypingExerciseView(
                            prompt: isHebrewToEnglish ? question.hebrew : question.english,
                            questionWord: question,
                            isHebrewToEnglish: isHebrewToEnglish,
                            onSubmit: { controller.checkAnswer($0) },
                            controller: controller
                        )
                        .id(question.id)
                    case .phraseTyping(let phrase):
                        TypingExerciseView(
                            prompt: phrase.english,
                            questionWord: nil,
                            isHebrewToEnglish: false, // Target is Hebrew
                            onSubmit: { controller.checkAnswer($0) },
                            controller: controller
                        )
                        .id(phrase.id)
                    case .prepositionPractice(let sentence, let options):
                        PrepositionExerciseView(
                            sentence: sentence,
                            options: options,
                            onOptionSelected: { controller.checkAnswer($0) },
                            controller: controller
                        )
                        .id(sentence.id)
                    case .verbConjugation(let fromForm, let toForm, let prompt):
                        VerbConjugationView(
                            fromForm: fromForm,
                            toForm: toForm,
                            prompt: prompt,
                            onSubmit: { controller.checkAnswer($0) },
                            controller: controller
                        )
                        .id("\(fromForm.hebrew)-\(toForm.hebrew)")
                    }
                }

                Spacer()
            }
        }
    }
}

struct HebrewView_Previews: PreviewProvider {
    static var previews: some View {
        HebrewView()
    }
}
