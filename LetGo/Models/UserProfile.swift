import Foundation
import CoreData

@objc(UserProfile)
public class UserProfile: NSManagedObject {
    @NSManaged public var nickname: String?
    @NSManaged public var imageData: Data?
} 