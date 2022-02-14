import ComposableArchitecture
import Foundation
import MatchClient
import Models
import World


public typealias AddMatchReducer = Reducer<AddMatchState, AddMatchAction, AddMatchEnvironment>

public struct AddMatchState: Equatable {
    public init(
        matchDate: Date = .now,
        playerScoreText: String = "",
        opponentScoreText: String = "",
        isWorkoutEnabled: Bool = false,
        workoutStartDate: Date = .now,
        workoutEndDate: Date = .now,
        activeCaloriesText: String = "",
        heartRateAverageText: String = "",
        heartRateMaxText: String = "",
        heartRateMinText: String = "",
        isSaveMatchRequestInFlight: Bool = false,
        alert: AlertState<AddMatchAction>? = nil
    ) {
        self.matchDate = matchDate
        self.playerScoreText = playerScoreText
        self.opponentScoreText = opponentScoreText
        self.isWorkoutEnabled = isWorkoutEnabled
        self.workoutStartDate = workoutStartDate
        self.workoutEndDate = workoutEndDate
        self.activeCaloriesText = activeCaloriesText
        self.heartRateAverageText = heartRateAverageText
        self.heartRateMaxText = heartRateMaxText
        self.heartRateMinText = heartRateMinText
        self.isSaveMatchRequestInFlight = isSaveMatchRequestInFlight
        self.alert = alert
    }
    
    @BindableState public var matchDate: Date
    @BindableState public var playerScoreText: String
    @BindableState public var opponentScoreText: String
    @BindableState public var isWorkoutEnabled: Bool
    @BindableState public var workoutStartDate: Date
    @BindableState public var workoutEndDate: Date
    @BindableState public var activeCaloriesText: String
    @BindableState public var heartRateAverageText: String
    @BindableState public var heartRateMaxText: String
    @BindableState public var heartRateMinText: String
    @BindableState public var isSaveMatchRequestInFlight: Bool
    @BindableState public var alert: AlertState<AddMatchAction>?
}

public enum AddMatchAction: Equatable, BindableAction {
    case binding(BindingAction<AddMatchState>)
    case saveButtonTapped
    case saveMatchResponse(Result<Match, MatchClient.Failure>)
    case alertOkayTapped
    case alertDismissed
}

public struct AddMatchEnvironment {
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        matchClient: MatchClient
    ) {
        self.mainQueue = mainQueue
        self.matchClient = matchClient
    }
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var matchClient: MatchClient
}

public let addMatchReducer = AddMatchReducer
{ state, action, environment in
    switch action {
    case let .saveMatchResponse(.failure(error)):
        state.alert = AlertState(
            title: .init("Sorry, something went wrong"),
            message: nil,
            dismissButton: .default(.init("Okay"), action: .send(.alertOkayTapped))
        )
        
        state.isSaveMatchRequestInFlight = false
        return .none
        
    case let .saveMatchResponse(.success(match)):
        state.isSaveMatchRequestInFlight = false
        return .none
        
    case .saveButtonTapped:
        let workout = Workout(
            id: Current.uuid(),
            startDate: state.workoutStartDate,
            endDate: state.workoutEndDate,
            activeCalories: Int(state.activeCaloriesText) ?? 0,
            heartRateAverage: Int(state.heartRateAverageText) ?? 0,
            heartRateMax: Int(state.heartRateMaxText) ?? 0,
            heartRateMin: Int(state.heartRateMinText) ?? 0
        )
        
        let match = Match(
            id: Current.uuid(),
            date: state.matchDate,
            playerScore: Int(state.playerScoreText) ?? 0,
            opponentScore: Int(state.opponentScoreText) ?? 0,
            workout: state.isWorkoutEnabled ? workout : nil
        )
        
        state.isSaveMatchRequestInFlight = true
        
        return environment.matchClient.create(match)
                .receive(on: environment.mainQueue)
                .catchToEffect(AddMatchAction.saveMatchResponse)
    default:
        return .none
    }
}
.binding()
