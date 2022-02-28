import ActiveMatchFeature
import ComposableArchitecture
import ComposableHelpers
import HealthKitClient
import MatchSeriesFeature
import Models
import Rally
import SwiftUI
import World
import WorkoutFeature

public typealias ActiveMatchTabReducer = Reducer<ActiveMatchTabState, ActiveMatchTabAction, ActiveMatchTabEnvironment>

// Important Note: -> Single first approach
// TODO: Match Series should handle a single match

public struct ActiveMatchTabState: Equatable {
    public init(
        activeMatchState: ActiveMatchState = .init(
            matchSettings: .init(
                id: .init(),
                createdDate: .now,
                isTrackingWorkout: false,
                isWinByTwo: true,
                name: "test",
                scoreLimit: 11,
                serveInterval: 2
            )
        ),
        matchControllerState: MatchControllerState = .init(),
        workoutState: WorkoutState? = .init()
    ) {
        self.activeMatchState = activeMatchState
        self.matchControllerState = MatchControllerState(isWorkoutAvailable: workoutState != nil)
        self.workoutState = workoutState
    }
    
    var activeMatchState: ActiveMatchState
    var matchControllerState: MatchControllerState
    @BindableState public var tabIndex: Int = 1
    var workoutState: WorkoutState?
}

public enum ActiveMatchTabAction: BindableAction {
    case binding(BindingAction<ActiveMatchTabState>)
    case workout(WorkoutAction)
    case activeMatch(ActiveMatchAction)
    case matchController(MatchControllerAction)
    case didAppear
}

public struct ActiveMatchTabEnvironment {
    public init(
        healthKitClient: HealthKitClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.healthKitClient = healthKitClient
        self.mainQueue = mainQueue
    }
    
    var healthKitClient: HealthKitClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

private let reducer = ActiveMatchTabReducer
{ state, action, environment in
    switch action {
    case .activeMatch(.rally(.statusChanged(.active))):
        if state.workoutState != nil {
            return Effect(value: .workout(.start))
        }
        
        return .none
        
    case .matchController(.workoutCancelled):
        guard state.workoutState != nil
        else { return .none }
        
        return Effect(value: .workout(.cancelWorkout))
        
    case .matchController(.pauseTapped):
        if state.matchControllerState.isPaused {
            var effects: [Effect<ActiveMatchTabAction, Never>] = [
                Effect(value: .activeMatch(.rally(.statusChanged(.paused))))
            ]
            
            if state.workoutState != nil {
                effects.append(Effect(value: .workout(.pause)))
            }
            
            // Pause Rally and pause workout
            return .merge(effects)
        } else {
            var effects: [Effect<ActiveMatchTabAction, Never>] = [
                Effect(value: .activeMatch(.rally(.statusChanged(.active))))
            ]
            
            if state.workoutState != nil {
                effects.append(Effect(value: .workout(.resume)))
            }
            
            return .merge(effects)
        }
        
    case .matchController(.matchCancelled):
        if state.workoutState != nil {
            return Effect(value: .workout(.cancelWorkout))
        }
        
        return .none
        
    case .didAppear:
        if state.workoutState != nil {
            return Effect(value: .workout(.viewDidAppear))
        }
        
        return .none
    default:
        return .none
    }
}
.binding()

public let activeMatchTabReducer: ActiveMatchTabReducer =
.combine(
    activeMatchReducer
        .pullback(
            state: \.activeMatchState,
            action: /ActiveMatchTabAction.activeMatch,
            environment: { _ in
                ActiveMatchEnvironment()
            }
        ),
    workoutReducer
        .optional()
        .pullback(
            state: \.workoutState,
            action: /ActiveMatchTabAction.workout,
            environment: {
                WorkoutEnvironment(
                    healthKitClient: $0.healthKitClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    matchControllerReducer
        .pullback(
            state: \.matchControllerState,
            action: /ActiveMatchTabAction.matchController,
            environment: { _ in
                .init()
            }
        ),
    reducer
)


public struct ActiveMatchTabView: View {
    let store: Store<ActiveMatchTabState, ActiveMatchTabAction>
    @ObservedObject var viewStore: ViewStore<ActiveMatchTabState, ActiveMatchTabAction>
    
    public init(
        store: Store<ActiveMatchTabState, ActiveMatchTabAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        TabView(selection: viewStore.binding(\.$tabIndex)) {
            IfLetStore(
                store.scope(
                    state: \.workoutState,
                    action: ActiveMatchTabAction.workout),
                then: WorkoutView.init(store:)
            )
            .tag(0)
            
            ActiveMatchView(
                store: store.scope(
                    state: \.activeMatchState,
                    action: ActiveMatchTabAction.activeMatch)
            )
            .tag(1)
            
            MatchControllerView(
                store: store.scope(
                    state: \.matchControllerState,
                    action: ActiveMatchTabAction.matchController)
            )
            .tag(2)
        }
        .onAppear {
            viewStore.send(.didAppear)
        }
    }
}

struct ActiveMatchTabView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ActiveMatchTabView(
                store: Store(
                    initialState: .init(),
                    reducer: activeMatchTabReducer,
                    environment: .init(healthKitClient: .live, mainQueue: .main)
                )
            )
        }
    }
}
