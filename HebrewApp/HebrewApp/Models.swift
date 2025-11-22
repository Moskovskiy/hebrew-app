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
