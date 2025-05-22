import Foundation

struct Writing: Identifiable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var type: WritingType
    
    init(id: UUID = UUID(), title: String, content: String, date: Date = Date(), type: WritingType) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.type = type
    }
} 