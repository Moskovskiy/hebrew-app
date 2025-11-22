import Foundation

struct Word: Codable, Identifiable, Equatable {
    var id: String { hebrew }
    let hebrew: String
    let english: String
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
