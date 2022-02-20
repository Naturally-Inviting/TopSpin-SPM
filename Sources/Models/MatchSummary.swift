import Foundation

public struct MatchSummary: Identifiable, Codable, Equatable {
    public init(
        id: UUID,
        dateRange: DateComponents,
        wins: Int,
        loses: Int,
        calories: Int,
        heartRateAverage: Int,
        matches: [Match]
    ) {
        self.id = id
        self.dateRange = dateRange
        self.wins = wins
        self.loses = loses
        self.calories = calories
        self.heartRateAverage = heartRateAverage
        self.matches = matches
    }
    
    public var id: UUID
    public var dateRange: DateComponents
    public var wins: Int
    public var loses: Int
    public var calories: Int
    public var heartRateAverage: Int
    public var matches: [Match]
    
    public func dateRange(in calendar: Calendar) -> String {
        guard let date = calendar.date(from: self.dateRange)
        else { return "n/a" }
        
        return date.formatted(.dateTime.month(.abbreviated).year())
    }
}
