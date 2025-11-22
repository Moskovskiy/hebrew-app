import Foundation

class ExerciseGenerator {
    private let dataManager = DataManager.shared
    
    func generateEnglishToHebrew() -> ExerciseType? {
        guard let correctWord = dataManager.words.randomElement() else { return nil }
        var options = [correctWord]
        let wrongOptions = dataManager.words.filter { $0.id != correctWord.id }.shuffled().prefix(9)
        options.append(contentsOf: wrongOptions)
        options.shuffle()
        return .englishToHebrew(question: correctWord, options: options)
    }
    
    func generateHebrewToEnglish() -> ExerciseType? {
        guard let correctWord = dataManager.words.randomElement() else { return nil }
        var options = [correctWord]
        let wrongOptions = dataManager.words.filter { $0.id != correctWord.id }.shuffled().prefix(9)
        options.append(contentsOf: wrongOptions)
        options.shuffle()
        return .hebrewToEnglish(question: correctWord, options: options)
    }
    
    func generatePhraseOrder() -> ExerciseType? {
        guard let phrase = dataManager.phrases.randomElement() else { return nil }
        let words = phrase.hebrew.components(separatedBy: " ").filter { !$0.isEmpty }
        return .phraseOrder(phrase: phrase, shuffledWords: words.shuffled())
    }
    
    func generateTypingPractice() -> ExerciseType? {
        guard let word = dataManager.words.randomElement() else { return nil }
        let isHebrewToEnglish = Bool.random()
        return .typingPractice(question: word, isHebrewToEnglish: isHebrewToEnglish)
    }
    
    func generatePrepositionPractice() -> ExerciseType? {
        guard let sentence = dataManager.prepositionSentences.randomElement() else { return nil }
        
        guard let category = dataManager.prepositionCategories.first(where: { $0.category == sentence.category }) else { return nil }
        
        var options = [sentence.correctPreposition]
        let wrongOptions = category.prepositions
            .map { $0.hebrew }
            .filter { $0 != sentence.correctPreposition }
            .shuffled()
            .prefix(3)
        options.append(contentsOf: wrongOptions)
        options.shuffle()
        
        return .prepositionPractice(sentence: sentence, options: Array(options))
    }
    
    func generatePhraseTyping() -> ExerciseType? {
        guard let phrase = dataManager.phrases.randomElement() else { return nil }
        return .phraseTyping(phrase: phrase)
    }
}
