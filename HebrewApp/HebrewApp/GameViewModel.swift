import Foundation
import SwiftUI
import Combine

enum ExerciseType: Equatable {
    case englishToHebrew(question: Word, options: [Word])
    case hebrewToEnglish(question: Word, options: [Word])
    case phraseOrder(phrase: Phrase, shuffledWords: [String])
    case typingPractice(question: Word, isHebrewToEnglish: Bool)
    case prepositionPractice(sentence: PrepositionSentence, options: [String])
}

class GameViewModel: ObservableObject {
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
    
    private var dataManager = DataManager.shared
    private var exerciseCounter: Int = 0
    
    init() {
        nextExercise()
    }
    
    func nextExercise() {
        feedbackMessage = nil
        showFeedback = false
        selectedWord = nil
        typingAttempts = 0
        showCorrectAnswer = false
        isCloseMatch = false
        
        exerciseCounter += 1
        
        // Rotate through 5 exercise types
        let exerciseType = exerciseCounter % 5
        
        switch exerciseType {
        case 1:
            generateEnglishToHebrew()
        case 2:
            generateHebrewToEnglish()
        case 3:
            generatePhraseOrder()
        case 4:
            generateTypingPractice()
        case 0: // 5th in cycle (0 because % 5)
            generatePrepositionPractice()
        default:
            generateEnglishToHebrew()
        }
    }
    
    private func generateEnglishToHebrew() {
        guard let correctWord = dataManager.words.randomElement() else { return }
        var options = [correctWord]
        let wrongOptions = dataManager.words.filter { $0.id != correctWord.id }.shuffled().prefix(9)
        options.append(contentsOf: wrongOptions)
        options.shuffle()
        currentExercise = .englishToHebrew(question: correctWord, options: options)
    }
    
    private func generateHebrewToEnglish() {
        guard let correctWord = dataManager.words.randomElement() else { return }
        var options = [correctWord]
        let wrongOptions = dataManager.words.filter { $0.id != correctWord.id }.shuffled().prefix(9)
        options.append(contentsOf: wrongOptions)
        options.shuffle()
        currentExercise = .hebrewToEnglish(question: correctWord, options: options)
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
    
    private func generateTypingPractice() {
        guard let word = dataManager.words.randomElement() else { 
            print("DEBUG: No words available for typing practice, falling back")
            generateEnglishToHebrew()
            return 
        }
        // Randomly choose direction
        let isHebrewToEnglish = Bool.random()
        currentExercise = .typingPractice(question: word, isHebrewToEnglish: isHebrewToEnglish)
    }
    
    private func generatePrepositionPractice() {
        guard let sentence = dataManager.prepositionSentences.randomElement() else {
            print("DEBUG: No preposition sentences available, falling back")
            generateEnglishToHebrew()
            return
        }
        
        // Get all prepositions from the same category for options
        guard let category = dataManager.prepositionCategories.first(where: { $0.category == sentence.category }) else {
            print("DEBUG: No category found, falling back")
            generateEnglishToHebrew()
            return
        }
        
        // Create options: correct answer + 3 random wrong answers from same category
        var options = [sentence.correctPreposition]
        let wrongOptions = category.prepositions
            .map { $0.hebrew }
            .filter { $0 != sentence.correctPreposition }
            .shuffled()
            .prefix(3)
        options.append(contentsOf: wrongOptions)
        options.shuffle()
        
        currentExercise = .prepositionPractice(sentence: sentence, options: Array(options))
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
        case .prepositionPractice(let sentence, _):
            if let selectedPreposition = answer as? String {
                isCorrect = selectedPreposition == sentence.correctPreposition
            }
        }
        
        if isCorrect {
            scoreCorrect += 1
            isCorrectAnswer = true
            
            // Determine feedback message based on close match
            if isCloseMatch, case .typingPractice(let question, let isHebrewToEnglish) = exercise {
                let correctAnswerText = isHebrewToEnglish ? question.english : question.hebrew
                feedbackMessage = "Close! Correct: \(correctAnswerText)"
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
            } else if answer is String { // This covers TypingPractice and PrepositionPractice
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
    // MARK: - Helper Methods
    
    private func normalize(_ text: String) -> String {
        // 1. Lowercase
        var normalized = text.lowercased()
        
        // 2. Remove whitespace and punctuation
        normalized = normalized.components(separatedBy: .whitespacesAndNewlines).joined()
        normalized = normalized.components(separatedBy: .punctuationCharacters).joined()
        
        // 3. Remove Hebrew Niqqudim (Vowels) - Unicode range 0591-05C7
        normalized = normalized.replacingOccurrences(of: "[\u{0591}-\u{05C7}]", with: "", options: .regularExpression)
        
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
