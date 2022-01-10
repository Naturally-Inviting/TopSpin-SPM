import Foundation
import Models
import World

public extension MatchMO {
    static func initFrom(_ match: Match) -> MatchMO {
        let context = Current.coreDataStack().context
        let managedObject = MatchMO(context: context)
        
        managedObject.id = match.id
        managedObject.date = match.date
        managedObject.playerScore = Int16(match.playerScore)
        managedObject.opponentScore = Int16(match.opponentScore)
        
        if let workout = match.workout {
            managedObject.workout = WorkoutMO.initFrom(workout)
        }
        
        return managedObject
    }
    
    func asMatch() -> Match {
        Match(
            id: self.id!,
            date: self.date,
            playerScore: Int(self.playerScore),
            opponentScore: Int(self.opponentScore),
            workout: self.workout?.asWorkout()
        )
    }
}

public extension MatchSettingMO {
    static func initFrom(_ settings: MatchSetting) -> MatchSettingMO {
        let context = Current.coreDataStack().context
        let managedObject = MatchSettingMO(context: context)
        
        managedObject.id = settings.id
        managedObject.createdDate = settings.createdDate
        managedObject.name = settings.name
        managedObject.isWinByTwo = settings.isWinByTwo
        managedObject.isTrackingWorkout = settings.isTrackingWorkout
        managedObject.scoreLimit = Int16(settings.scoreLimit)
        managedObject.serviceInterval = Int16(settings.serveInterval)
        
        return managedObject
    }
    
    func asMatchSetting() -> MatchSetting {
        MatchSetting(
            id: self.id!,
            createdDate: self.createdDate,
            isTrackingWorkout: self.isTrackingWorkout,
            isWinByTwo: self.isWinByTwo,
            name: self.name,
            scoreLimit: Int(self.scoreLimit),
            serveInterval: Int(self.serviceInterval)
        )
    }
}

public extension WorkoutMO {
    static func initFrom(_ workout: Workout) -> WorkoutMO {
        let context = Current.coreDataStack().context
        let managedObject = WorkoutMO(context: context)
        
        managedObject.id = workout.id
        managedObject.startDate = workout.startDate
        managedObject.endDate = workout.endDate
        managedObject.activeCalories = Int16(workout.activeCalories)
        managedObject.heartRateAverage = Int16(workout.heartRateAverage)
        managedObject.heartRateMax = Int16(workout.heartRateMax)
        managedObject.heartRateMin = Int16(workout.heartRateMin)
        
        return managedObject
    }
    
    func asWorkout() -> Workout {
        Workout(
            id: self.id!,
            startDate: self.startDate,
            endDate: self.endDate,
            activeCalories: Int(self.activeCalories),
            heartRateAverage: Int(self.heartRateAverage),
            heartRateMax: Int(self.heartRateMax),
            heartRateMin: Int(self.heartRateMin)
        )
    }
}
