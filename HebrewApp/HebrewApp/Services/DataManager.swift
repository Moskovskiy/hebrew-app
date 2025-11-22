import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var words: [Word] = []
    @Published var phrases: [Phrase] = []
    @Published var prepositionCategories: [PrepositionCategory] = []
    @Published var prepositionSentences: [PrepositionSentence] = []
    @Published var verbs: [VerbConjugation] = []
    @Published var arabicLetters: [ArabicLetter] = []
    @Published var arabicWords: [ArabicWord] = []
    @Published var hardEnglishWords: [HardEnglishWord] = []

    private init() {
        loadData()
    }

    func loadData() {
        words = load("words.json")
        phrases = load("phrases.json")
        prepositionCategories = load("prepositions.json")
        prepositionSentences = load("preposition_sentences.json")
        verbs = load("verbs.json")
        arabicLetters = load("arabic_letters.json")
        arabicWords = load("arabic_words.json")
        hardEnglishWords = load("hard_english_words.json")
    }
    
    private func load<T: Decodable>(_ filename: String) -> T {
        let data: Data
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}
