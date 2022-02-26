import ActiveMatchFeature
import ComposableArchitecture
import ComposableHelpers
import HealthKitClient
import MatchSeriesFeature
import Rally
import SwiftUI
import World
import WorkoutFeature

typealias MatchControllerReducer = Reducer<MatchControllerState, MatchControllerAction, MatchControllerEnvironment>

struct MatchControllerState: Equatable {
    var alert: AlertState<MatchControllerAction>? = nil
}

enum MatchControllerAction: Equatable {
    case pause
    case cancel
    case cancelWorkout
}

struct MatchControllerEnvironment {
    
}

let matchControllerReducer = MatchControllerReducer
{ state, action, environment in
    switch action {
    default:
        return .none
    }
}

// Important Note: -> Single first approach
// TODO: Match Series should handle a single match

public struct ActiveMatchTabState: Equatable {
    
    var activeMatchState: ActiveMatchState
    @BindableState public var tabIndex: Int
    var workoutState: WorkoutState?
}
