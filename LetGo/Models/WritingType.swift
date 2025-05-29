import Foundation

enum WritingType: String, CaseIterable {
    case threeMin = "three_min"
    case fiveMin = "five_min"
    case sevenMin = "seven_min"
    case oneLine = "one_line"
    case free = "write_free"
    
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
    
    var icon: String {
        switch self {
        case .threeMin: return "timer"
        case .fiveMin: return "timer"
        case .sevenMin: return "timer"
        case .oneLine: return "text.quote"
        case .free: return "square.and.pencil"
        }
    }
} 
