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

    func generateVerbConjugation() -> ExerciseType? {
        guard let verb = dataManager.verbs.randomElement() else { return nil }

        // Get all conjugation forms
        let allForms: [(VerbForm, String)] = [
            (verb.pastFirstSingular, "I (past)"),
            (verb.pastSecondMasculine, "you masculine (past)"),
            (verb.pastSecondFeminine, "you feminine (past)"),
            (verb.pastThirdMasculine, "he (past)"),
            (verb.pastThirdFeminine, "she (past)"),
            (verb.pastFirstPlural, "we (past)"),
            (verb.pastSecondPlural, "you plural (past)"),
            (verb.pastThirdPlural, "they (past)"),
            (verb.presentMasculineSingular, "masculine singular (present)"),
            (verb.presentFeminineSingular, "feminine singular (present)"),
            (verb.presentMasculinePlural, "masculine plural (present)"),
            (verb.presentFemininePlural, "feminine plural (present)"),
            (verb.futureFirstSingular, "I (future)"),
            (verb.futureSecondMasculine, "you masculine (future)"),
            (verb.futureSecondFeminine, "you feminine (future)"),
            (verb.futureThirdMasculine, "he (future)"),
            (verb.futureThirdFeminine, "she (future)"),
            (verb.futureFirstPlural, "we (future)"),
            (verb.futureSecondPlural, "you plural (future)"),
            (verb.futureThirdPlural, "they (future)")
        ]

        // Pick two different random forms
        guard let fromIndex = (0..<allForms.count).randomElement(),
              let toIndex = (0..<allForms.count).filter({ $0 != fromIndex }).randomElement() else {
            return nil
        }

        let fromForm = allForms[fromIndex].0
        let toFormData = allForms[toIndex]
        let prompt = "Type the form for \(toFormData.1):"

        return .verbConjugation(fromForm: fromForm, toForm: toFormData.0, prompt: prompt)
    }
}
