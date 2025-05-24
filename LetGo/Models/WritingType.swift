import Foundation

enum WritingType: String, CaseIterable {
    case threeMin = "3분세션"
    case fiveMin = "5분세션"
    case sevenMin = "7분세션"
    case oneLine = "오늘의한마디"
    
    var icon: String {
        switch self {
        case .threeMin: return "timer"
        case .fiveMin: return "timer"
        case .sevenMin: return "timer"
        case .oneLine: return "text.quote"
        }
    }
} 