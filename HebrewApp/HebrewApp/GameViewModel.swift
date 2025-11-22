import Foundation
import SwiftUI
import Combine

enum ExerciseType {
    case englishToHebrew(question: Word, options: [Word])
    case hebrewToEnglish(question: Word, options: [Word])
    case phraseOrder(phrase: Phrase, shuffledWords: [String])
}

class GameViewModel: ObservableObject {
    @Published var currentExercise: ExerciseType?
    @Published var scoreCorrect: Int = 0
    @Published var scoreWrong: Int = 0
    @Published var feedbackMessage: String?
    @Published var isCorrectAnswer: Bool = false
    @Published var selectedWord: Word?
    @Published var showFeedback: Bool = false
    
    private var dataManager = DataManager.shared
    
    init() {
        nextExercise()
    }
    
    func nextExercise() {
        feedbackMessage = nil
        showFeedback = false
        selectedWord = nil
        let type = Int.random(in: 0...2)
        
        switch type {
        case 0:
            generateEnglishToHebrew()
        case 1:
            generateHebrewToEnglish()
        case 2:
            generatePhraseOrder()
        default:
            generateEnglishToHebrew()
        }
    }
    
    private func generateEnglishToHebrew() {
        guard let correctWord = dataManager.words.randomElement() else { return }
        var options = [correctWord]
        while options.count < 6 {
            if let randomWord = dataManager.words.randomElement(), !options.contains(randomWord) {
                options.append(randomWord)
            }
        }
        currentExercise = .englishToHebrew(question: correctWord, options: options.shuffled())
    }
    
    private func generateHebrewToEnglish() {
        guard let correctWord = dataManager.words.randomElement() else { return }
        var options = [correctWord]
        while options.count < 6 {
            if let randomWord = dataManager.words.randomElement(), !options.contains(randomWord) {
                options.append(randomWord)
            }
        }
        currentExercise = .hebrewToEnglish(question: correctWord, options: options.shuffled())
    }
    
    private func generatePhraseOrder() {
        print("DEBUG: Attempting to generate phrase exercise")
        print("DEBUG: Phrases count: \(dataManager.phrases.count)")
        guard let phrase = dataManager.phrases.randomElement() else { 
            print("DEBUG: No phrases available, falling back to English->Hebrew")
            generateEnglishToHebrew()
            return 
        }
        let words = phrase.hebrew.components(separatedBy: " ").filter { !$0.isEmpty }
        print("DEBUG: Generated phrase exercise with \(words.count) words")
        currentExercise = .phraseOrder(phrase: phrase, shuffledWords: words.shuffled())
    }
    
    func checkAnswer(_ answer: Any) {
        guard let exercise = currentExercise else { return }
        
        var isCorrect = false
        
        switch exercise {
        case .englishToHebrew(let question, _):
            if let selectedWord = answer as? Word {
                isCorrect = selectedWord.id == question.id
            }
        case .hebrewToEnglish(let question, _):
            if let selectedWord = answer as? Word {
                isCorrect = selectedWord.id == question.id
            }
        case .phraseOrder(let phrase, _):
            if let orderedWords = answer as? [String] {
                let constructedPhrase = orderedWords.joined(separator: " ")
                isCorrect = constructedPhrase == phrase.hebrew
            }
        }
        
        if isCorrect {
            scoreCorrect += 1
            isCorrectAnswer = true
            feedbackMessage = "Correct!"
            
            // Determine delay based on exercise type
            let delay: Double
            if let word = answer as? Word {
                // Word exercises: show visual feedback
                selectedWord = word
                showFeedback = true
                delay = 1.5
            } else {
                // Phrase exercises: move to next immediately
                delay = 0.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.nextExercise()
            }
        } else {
            scoreWrong += 1
            isCorrectAnswer = false
            feedbackMessage = "Try again!"
            
            // Set selected word for visual feedback (only for word exercises)
            if let word = answer as? Word {
                selectedWord = word
                showFeedback = true
                
                // Clear feedback after a short delay for wrong answers
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showFeedback = false
                    self.selectedWord = nil
                }
            }
        }
    }
}
