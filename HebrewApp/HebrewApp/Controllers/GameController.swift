import Foundation
import SwiftUI
import Combine

class GameController: ObservableObject {
    // MARK: - State
    @Published var currentExercise: ExerciseType?
    @Published var scoreCorrect: Int = 0
    @Published var scoreWrong: Int = 0
    @Published var feedbackMessage: String?
    @Published var isCorrectAnswer: Bool = false
    @Published var selectedWord: Word?
    @Published var showFeedback: Bool = false
    @Published var typingAttempts: Int = 0
    @Published var showCorrectAnswer: Bool = false
    @Published var isCloseMatch: Bool = false
    
    // MARK: - Dependencies
    private let generator = ExerciseGenerator()
    private var exerciseCounter: Int = 0
    
    // MARK: - Initialization
    init() {
        nextExercise()
    }
    
    // MARK: - Game Flow
    func nextExercise() {
        // Reset State
        feedbackMessage = nil
        showFeedback = false
        selectedWord = nil
        typingAttempts = 0
        showCorrectAnswer = false
        isCloseMatch = false
        
        exerciseCounter += 1
        
        // Rotate through 6 exercise types
        // 1: Eng->Heb, 2: Heb->Eng, 3: Phrase, 4: Typing, 5: Phrase Typing, 0: Preposition
        let exerciseTypeIndex = exerciseCounter % 6
        
        switch exerciseTypeIndex {
        case 1:
            currentExercise = generator.generateEnglishToHebrew()
        case 2:
            currentExercise = generator.generateHebrewToEnglish()
        case 3:
            currentExercise = generator.generatePhraseOrder()
        case 4:
            currentExercise = generator.generateTypingPractice()
        case 5:
            currentExercise = generator.generatePhraseTyping()
        case 0:
            currentExercise = generator.generatePrepositionPractice()
        default:
            currentExercise = generator.generateEnglishToHebrew()
        }
        
        // Fallback if generation failed
        if currentExercise == nil {
            currentExercise = generator.generateEnglishToHebrew()
        }
    }
    
    // MARK: - User Actions
    func giveUp() {
        scoreWrong += 1
        isCorrectAnswer = false
        showCorrectAnswer = true
        feedbackMessage = "Correct answer shown"
        
        // Move to next exercise after showing answer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.nextExercise()
        }
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
        case .typingPractice(let question, let isHebrewToEnglish):
            if let typedText = answer as? String {
                let correctAnswer = isHebrewToEnglish ? question.english : question.hebrew
                
                // 1. Normalize both strings
                let normalizedInput = normalize(typedText)
                let normalizedTarget = normalize(correctAnswer)
                
                // 2. Check exact match (after normalization)
                if normalizedInput == normalizedTarget {
                    isCorrect = true
                } 
                // 3. Check fuzzy match (if not English)
                else if !isHebrewToEnglish && isFuzzyMatch(normalizedInput, normalizedTarget) {
                    isCorrect = true
                    isCloseMatch = true // Flag for UI to show "Close!" message
                }
            }
        case .phraseTyping(let phrase):
            if let typedText = answer as? String {
                let correctAnswer = phrase.hebrew
                
                let normalizedInput = normalize(typedText)
                let normalizedTarget = normalize(correctAnswer)
                
                if normalizedInput == normalizedTarget {
                    isCorrect = true
                } else if isFuzzyMatch(normalizedInput, normalizedTarget) {
                    isCorrect = true
                    isCloseMatch = true
                }
            }
        case .prepositionPractice(let sentence, _):
            if let selectedPreposition = answer as? String {
                isCorrect = selectedPreposition == sentence.correctPreposition
            }
        }
        
        handleResult(isCorrect: isCorrect, answer: answer, exercise: exercise)
    }
    
    // MARK: - Internal Logic
    private func handleResult(isCorrect: Bool, answer: Any, exercise: ExerciseType) {
        if isCorrect {
            scoreCorrect += 1
            isCorrectAnswer = true
            
            // Determine feedback message based on close match
            if isCloseMatch {
                if case .typingPractice(let question, let isHebrewToEnglish) = exercise {
                    let correctAnswerText = isHebrewToEnglish ? question.english : question.hebrew
                    feedbackMessage = "Close! Correct: \(correctAnswerText)"
                } else if case .phraseTyping(let phrase) = exercise {
                    feedbackMessage = "Close! Correct: \(phrase.hebrew)"
                }
            } else {
                feedbackMessage = "Correct!"
            }
            
            // Determine delay based on exercise type
            let delay: Double
            if let word = answer as? Word {
                // Word exercises: show visual feedback
                selectedWord = word
                showFeedback = true
                delay = 1.5
            } else if answer is String { // This covers TypingPractice, PhraseTyping and PrepositionPractice
                showFeedback = true
                // Longer delay for close matches to read the correction
                delay = isCloseMatch ? 2.5 : 0.5
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
                    self.feedbackMessage = nil
                }
            } else if case .typingPractice = exercise {
                handleTypingFailure()
            } else if case .phraseTyping = exercise {
                handleTypingFailure()
            } else if case .prepositionPractice = exercise {
                // For preposition exercises, show feedback
                showFeedback = true
                
                // Clear feedback after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showFeedback = false
                    self.feedbackMessage = nil
                }
            } else {
                // For phrase exercises, clear feedback after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.feedbackMessage = nil
                }
            }
        }
    }
    
    private func handleTypingFailure() {
        // For typing exercises, track attempts
        typingAttempts += 1
        
        if typingAttempts >= 3 {
            // Show correct answer after 3 attempts
            showCorrectAnswer = true
            feedbackMessage = "Correct answer shown"
            
            // Move to next exercise after showing answer
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.nextExercise()
            }
        } else {
            // Clear feedback after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.feedbackMessage = nil
            }
        }
    }
    
    private func normalize(_ text: String) -> String {
        // 1. Lowercase
        var normalized = text.lowercased()
        
        // 2. Remove whitespace and punctuation
        normalized = normalized.components(separatedBy: .whitespacesAndNewlines).joined()
        normalized = normalized.components(separatedBy: .punctuationCharacters).joined()
        
        // 3. Remove Hebrew Niqqudim (Vowels) - Unicode range 0591-05C7
        normalized = normalized.replacingOccurrences(of: "[\\u{0591}-\\u{05C7}]", with: "", options: .regularExpression)
        
        return normalized
    }
    
    private func isFuzzyMatch(_ input: String, _ target: String) -> Bool {
        // Create "skeleton" by replacing confusable characters with a representative
        func skeleton(_ text: String) -> String {
            var s = text
            // Replace confusables
            s = s.replacingOccurrences(of: "ח", with: "ה")
            s = s.replacingOccurrences(of: "כ", with: "ק") // Kaf/Qof
            s = s.replacingOccurrences(of: "ט", with: "ת") // Tet/Tav
            s = s.replacingOccurrences(of: "ס", with: "ש") // Samekh/Shin (Sin) - simplified
            s = s.replacingOccurrences(of: "א", with: "ע") // Aleph/Ayin
            s = s.replacingOccurrences(of: "ו", with: "ב") // Vet/Vav (sometimes confused)
            return s
        }
        
        return skeleton(input) == skeleton(target)
    }
}
