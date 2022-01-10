import Foundation
import Models

struct WorkoutStatsViewContent {
    let startDate: Date
    let endDate: Date
    
    let calories: Int
    let heartRateAverage: Int
    let heartRateMax: Int
    let heartRateMin: Int
    
    var duration: String {
        let timeInterval = endDate.timeIntervalSince(startDate)
        let timePassed = timeInterval.truncatingRemainder(dividingBy: 3600) / 60
        return "\(Int(timePassed))"
    }
}

extension WorkoutStatsViewContent {
    init(workout: Workout) {
        self.startDate = workout.startDate
        self.endDate = workout.endDate
        self.calories = workout.activeCalories
        self.heartRateAverage = workout.heartRateAverage
        self.heartRateMax = workout.heartRateMax
        self.heartRateMin = workout.heartRateMin
    }
}
