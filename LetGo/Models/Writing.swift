import Foundation
import CoreData

@objc(Writing)
public class Writing: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Writing> {
        return NSFetchRequest<Writing>(entityName: "Writing")
    }

    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var date: Date
    @NSManaged public var type: String
    @NSManaged public var isLiked: Bool

    var writingType: WritingType {
        WritingType(rawValue: type) ?? .threeMin
    }

    convenience init(context: NSManagedObjectContext, title: String, content: String, date: Date, type: WritingType) {
        let entity = NSEntityDescription.entity(forEntityName: "Writing", in: context)!
        self.init(entity: entity, insertInto: context)
        self.title = title
        self.content = content
        self.date = date
        self.type = type.rawValue
        self.isLiked = false
    }
} 