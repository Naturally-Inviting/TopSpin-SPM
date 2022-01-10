import Foundation
import CoreData

public final class WorkoutMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var activeCalories: Int16
    @NSManaged public var heartRateAverage: Int16
    @NSManaged public var heartRateMax: Int16
    @NSManaged public var heartRateMin: Int16
}
