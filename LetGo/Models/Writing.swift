import Foundation
import SwiftData

@Model
class Writing {
    @Attribute var title: String
    @Attribute var content: String
    @Attribute var date: Date
    @Attribute var type: String // Store WritingType as String
    @Attribute var isLiked: Bool = false // 좋아요 여부
    
    init(title: String, content: String, date: Date, type: WritingType) {
        self.title = title
        self.content = content
        self.date = date
        self.type = type.rawValue
    }
    
    var writingType: WritingType {
        WritingType(rawValue: type) ?? .threeMin
    }
} 