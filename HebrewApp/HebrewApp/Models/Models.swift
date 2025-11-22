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

enum ExerciseType: Equatable {
    case englishToHebrew(question: Word, options: [Word])
    case hebrewToEnglish(question: Word, options: [Word])
    case phraseOrder(phrase: Phrase, shuffledWords: [String])
    case typingPractice(question: Word, isHebrewToEnglish: Bool)
    case phraseTyping(phrase: Phrase)
    case prepositionPractice(sentence: PrepositionSentence, options: [String])
}
