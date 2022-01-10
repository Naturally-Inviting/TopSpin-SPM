import Foundation

public struct MatchSummary: Identifiable, Codable, Equatable {
    public init(
        id: UUID,
        monthRange: Date,
        wins: Int,
        loses: Int,
        calories: Int,
        avgHeartRate: Int,
        matches: [Match]
    ) {
        self.id = id
        self.monthRange = monthRange
        self.wins = wins
        self.loses = loses
        self.calories = calories
        self.avgHeartRate = avgHeartRate
        self.matches = matches
    }
    
    public var id: UUID
    public var monthRange: Date
    public var wins: Int
    public var loses: Int
    public var calories: Int
    public var avgHeartRate: Int
    public var matches: [Match]
}

extension MatchSummary {
    public var dateRange: String {
        let dateFormmater = DateFormatter()
        dateFormmater.dateFormat = "MMM yyyy"
        return dateFormmater.string(from: monthRange)
    }
}
