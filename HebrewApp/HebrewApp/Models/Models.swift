import Foundation

struct Word: Codable, Identifiable, Equatable {
    var id: String { hebrew }
    let hebrew: String
    let english: String
    let root: [String]?
    let construction: String?
}

struct Phrase: Codable, Identifiable, Equatable {
    var id: String { hebrew }
    let hebrew: String
    let english: String
    let construction: String?
}

struct PrepositionItem: Codable {
    let hebrew: String
    let english: String
}

struct PrepositionCategory: Identifiable, Codable {
    var id = UUID()
    let category: String
    let categoryEnglish: String
    let prepositions: [PrepositionItem]
    
    enum CodingKeys: String, CodingKey {
        case category, categoryEnglish, prepositions
    }
}

struct PrepositionSentence: Identifiable, Codable, Equatable {
    var id = UUID()
    let hebrew: String
    let english: String
    let correctPreposition: String
    let category: String

    enum CodingKeys: String, CodingKey {
        case hebrew, english, correctPreposition, category
    }
}

struct VerbForm: Codable, Equatable {
    let hebrew: String
    let english: String
    let pronunciation: String
    let exampleSentence: String?
}

struct VerbConjugation: Identifiable, Codable, Equatable {
    var id: String { infinitive }
    let infinitive: String
    let infinitiveEnglish: String
    let root: [String]?

    // Past tense
    let pastFirstSingular: VerbForm       // I (אני)
    let pastSecondMasculine: VerbForm     // You masculine (אתה)
    let pastSecondFeminine: VerbForm      // You feminine (את)
    let pastThirdMasculine: VerbForm      // He (הוא)
    let pastThirdFeminine: VerbForm       // She (היא)
    let pastFirstPlural: VerbForm         // We (אנחנו)
    let pastSecondPlural: VerbForm        // You plural (אתם/אתן)
    let pastThirdPlural: VerbForm         // They (הם/הן)

    // Present tense
    let presentMasculineSingular: VerbForm
    let presentFeminineSingular: VerbForm
    let presentMasculinePlural: VerbForm
    let presentFemininePlural: VerbForm

    // Future tense
    let futureFirstSingular: VerbForm      // I (אני)
    let futureSecondMasculine: VerbForm    // You masculine (אתה)
    let futureSecondFeminine: VerbForm     // You feminine (את)
    let futureThirdMasculine: VerbForm     // He (הוא)
    let futureThirdFeminine: VerbForm      // She (היא)
    let futureFirstPlural: VerbForm        // We (אנחנו)
    let futureSecondPlural: VerbForm       // You plural (אתם/אתן)
    let futureThirdPlural: VerbForm        // They (הם/הן)
}

enum ExerciseType: Equatable {
    case englishToHebrew(question: Word, options: [Word])
    case hebrewToEnglish(question: Word, options: [Word])
    case phraseOrder(phrase: Phrase, shuffledWords: [String])
    case typingPractice(question: Word, isHebrewToEnglish: Bool)
    case phraseTyping(phrase: Phrase)
    case prepositionPractice(sentence: PrepositionSentence, options: [String])
    case verbConjugation(fromForm: VerbForm, toForm: VerbForm, prompt: String)
}
