import Foundation

struct JournalEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var date = Date()
    var title: String
    var body: String
    var mood: Mood
    var photoData: Data?

    enum Mood: String, Codable, CaseIterable {
        case great, good, okay, low
        var emoji: String {
            switch self {
            case .great: "😄"
            case .good: "🙂"
            case .okay: "😐"
            case .low: "😔"
            }
        }
    }
}
