import Foundation

public struct Workout: Equatable, Codable {
    public init(
        id: UUID,
        startDate: Date,
        endDate: Date,
        activeCalories: Int,
        heartRateAverage: Int,
        heartRateMax: Int,
        heartRateMin: Int
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.activeCalories = activeCalories
        self.heartRateAverage = heartRateAverage
        self.heartRateMax = heartRateMax
        self.heartRateMin = heartRateMin
    }
    
    public var id: UUID
    public var startDate: Date
    public var endDate: Date
    public var activeCalories: Int
    public var heartRateAverage: Int
    public var heartRateMax: Int
    public var heartRateMin: Int
}

extension Workout {
    public var duration: String {
        let timeInterval = endDate.timeIntervalSince(startDate)
        let timePassed = timeInterval.truncatingRemainder(dividingBy: 3600)
        return Workout.elapsedTimeString(elapsed: Workout.secondsToHoursMinutesSeconds(seconds: Int(timePassed)))
    }
    
    public var timeFrame: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let start = dateFormatter.string(from: startDate).lowercased()
        let end = dateFormatter.string(from: endDate).lowercased()
        
        return "\(start) - \(end)"
    }
    
    // Convert the seconds into seconds, minutes, hours.
    static func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    // Convert the seconds, minutes, hours into a string.
    static func elapsedTimeString(elapsed: (h: Int, m: Int, s: Int)) -> String {
        return String(format: "%d:%02d:%02d", elapsed.h, elapsed.m, elapsed.s)
    }
}
