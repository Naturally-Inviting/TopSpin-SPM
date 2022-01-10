import Foundation

public struct Match: Equatable, Identifiable, Codable {
    public init(
        id: UUID,
        date: Date,
        playerScore: Int,
        opponentScore: Int,
        workout: Workout? = nil
    ) {
        self.id = id
        self.date = date
        self.playerScore = playerScore
        self.opponentScore = opponentScore
        self.workout = workout
    }
    
    public var id: UUID
    public var date: Date
    public var playerScore: Int
    public var opponentScore: Int
    public var workout: Workout?
}

public extension Match {
    var shortDate: String {
        let dateFormmater = DateFormatter()
        dateFormmater.dateFormat = "MMM d"
        
        return dateFormmater.string(from: date)
    }
    
    var startTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: date).lowercased()
    }
}
