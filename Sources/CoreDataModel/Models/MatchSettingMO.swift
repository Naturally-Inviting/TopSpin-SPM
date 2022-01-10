import Foundation
import CoreData

public final class MatchSettingMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var createdDate: Date
    @NSManaged public var name: String
    @NSManaged public var isWinByTwo: Bool
    @NSManaged public var isTrackingWorkout: Bool
    @NSManaged public var scoreLimit: Int16
    @NSManaged public var serviceInterval: Int16
}
