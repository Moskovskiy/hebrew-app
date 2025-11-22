import Foundation
import SwiftUI
import Combine

class ArabicGameController: ObservableObject {
    // MARK: - State
    @Published var currentExercise: ArabicExerciseType?
    @Published var scoreCorrect: Int = 0
    @Published var scoreWrong: Int = 0
    @Published var feedbackMessage: String?
    @Published var isCorrectAnswer: Bool = false
    @Published var showFeedback: Bool = false
    
    // MARK: - Dependencies
    private let dataManager = DataManager.shared
    
    // MARK: - Initialization
    init() {
        nextExercise()
    }
    
    // MARK: - Game Flow
    func nextExercise() {
        // Reset State
        feedbackMessage = nil
        showFeedback = false
        
        // Randomly choose between letter and word exercises
        if Bool.random() {
            generateLetterExercise()
        } else {
            generateWordExercise()
        }
    }
    
    private func generateLetterExercise() {
        guard !dataManager.arabicLetters.isEmpty else { return }
        
        let question = dataManager.arabicLetters.randomElement()!
        var options = [question]
        
        // Generate 9 distractors (total 10 options)
        while options.count < 10 {
            if let randomLetter = dataManager.arabicLetters.randomElement(), !options.contains(randomLetter) {
                options.append(randomLetter)
            }
            // Safety break if not enough letters
            if options.count == dataManager.arabicLetters.count { break }
        }
        
        options.shuffle()
        currentExercise = .letterToSound(question: question, options: options)
    }
    
    private func generateWordExercise() {
        guard !dataManager.arabicWords.isEmpty else { return }
        
        let question = dataManager.arabicWords.randomElement()!
        var options = [question]
        
        // Generate 9 distractors (total 10 options)
        while options.count < 10 {
            if let randomWord = dataManager.arabicWords.randomElement(), !options.contains(randomWord) {
                options.append(randomWord)
            }
            // Safety break if not enough words
            if options.count == dataManager.arabicWords.count { break }
        }
        
        options.shuffle()
        currentExercise = .wordToEnglish(question: question, options: options)
    }
    
    // MARK: - User Actions
    func checkAnswer(_ answer: Any) {
        guard let exercise = currentExercise else { return }
        
        var isCorrect = false
        
        switch exercise {
        case .letterToSound(let question, _):
            if let selectedLetter = answer as? ArabicLetter {
                isCorrect = selectedLetter.id == question.id
            }
        case .wordToEnglish(let question, _):
            if let selectedWord = answer as? ArabicWord {
                isCorrect = selectedWord.id == question.id
            }
        }
        
        handleResult(isCorrect: isCorrect)
    }
    
    private func handleResult(isCorrect: Bool) {
        if isCorrect {
            scoreCorrect += 1
            isCorrectAnswer = true
            feedbackMessage = "Correct!"
            showFeedback = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.nextExercise()
            }
        } else {
            scoreWrong += 1
            isCorrectAnswer = false
            feedbackMessage = "Try again!"
            showFeedback = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showFeedback = false
                self.feedbackMessage = nil
            }
        }
    }
}
