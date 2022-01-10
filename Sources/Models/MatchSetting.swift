import Foundation

public struct MatchSetting: Equatable, Identifiable {
    public init(
        id: UUID,
        createdDate: Date,
        isTrackingWorkout: Bool,
        isWinByTwo: Bool,
        name: String,
        scoreLimit: Int,
        serveInterval: Int
    ) {
        self.id = id
        self.createdDate = createdDate
        self.isTrackingWorkout = isTrackingWorkout
        self.isWinByTwo = isWinByTwo
        self.name = name
        self.scoreLimit = scoreLimit
        self.serveInterval = serveInterval
    }
    
    public var id: UUID
    public var createdDate: Date
    public var isTrackingWorkout: Bool
    public var isWinByTwo: Bool
    public var name: String
    public var scoreLimit: Int
    public var serveInterval: Int
}
