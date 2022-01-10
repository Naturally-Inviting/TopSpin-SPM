import Foundation
import CoreData

public final class MatchMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date
    @NSManaged public var playerScore: Int16
    @NSManaged public var opponentScore: Int16
    @NSManaged public var workout: WorkoutMO?
}
