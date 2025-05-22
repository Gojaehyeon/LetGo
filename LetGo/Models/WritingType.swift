import Foundation

enum WritingType: String, CaseIterable {
    case daily = "일상"
    case thought = "생각"
    case memory = "추억"
    case oneLine = "한마디"
    
    var icon: String {
        switch self {
        case .daily: return "book.fill"
        case .thought: return "brain.head.profile"
        case .memory: return "photo.fill"
        case .oneLine: return "text.quote"
        }
    }
} 