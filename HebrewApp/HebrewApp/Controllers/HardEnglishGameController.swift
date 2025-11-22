import Foundation
import SwiftUI
import Combine

class HardEnglishGameController: ObservableObject {
    // MARK: - State
    @Published var currentExercise: HardEnglishExerciseType?
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
        
        generateDefinitionExercise()
    }
    
    private func generateDefinitionExercise() {
        guard !dataManager.hardEnglishWords.isEmpty else { return }
        
        let question = dataManager.hardEnglishWords.randomElement()!
        var options = [question]
        
        // Generate 9 distractors (total 10 options)
        while options.count < 10 {
            if let randomWord = dataManager.hardEnglishWords.randomElement(), !options.contains(randomWord) {
                options.append(randomWord)
            }
            // Safety break if not enough words
            if options.count == dataManager.hardEnglishWords.count { break }
        }
        
        options.shuffle()
        currentExercise = .definitionToWord(question: question, options: options)
    }
    
    // MARK: - User Actions
    func checkAnswer(_ answer: Any) {
        guard let exercise = currentExercise else { return }
        
        var isCorrect = false
        
        switch exercise {
        case .definitionToWord(let question, _):
            if let selectedWord = answer as? HardEnglishWord {
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
