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

// MARK: - Match Controller

public typealias MatchControllerReducer = Reducer<MatchControllerState, MatchControllerAction, MatchControllerEnvironment>

public struct MatchControllerState: Equatable {
    var isPaused: Bool = false
    var alert: AlertState<MatchControllerAction>? = nil
}

public enum MatchControllerAction: Equatable {
    case pauseTapped
    case cancel
    case cancelWorkout
    
    case matchCancelled
}

public struct MatchControllerEnvironment {
}

public let matchControllerReducer = MatchControllerReducer
{ state, action, environment in
    switch action {
    case .pauseTapped:
        state.isPaused.toggle()
        return .none
        
    default:
        return .none
    }
}

public struct MatchControllerView: View {
    let store: Store<MatchControllerState, MatchControllerAction>
    @ObservedObject var viewStore: ViewStore<MatchControllerState, MatchControllerAction>
    
    public init(
        store: Store<MatchControllerState, MatchControllerAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        VStack {
            HStack {
                Button(action: { viewStore.send(.cancel) }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderedButtonStyle(tint: .red))
                
                Button(action: { viewStore.send(.pauseTapped) }) {
                    Image(systemName: viewStore.isPaused ? "pause" : "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
                .buttonStyle(BorderedButtonStyle(tint: .yellow))
            }
        }
    }
}

// MARK: - Match Tab View

public typealias ActiveMatchTabReducer = Reducer<ActiveMatchTabState, ActiveMatchTabAction, ActiveMatchTabEnvironment>

// Important Note: -> Single first approach
// TODO: Match Series should handle a single match

public struct ActiveMatchTabState: Equatable {
    var activeMatchState: ActiveMatchState = .init(
        matchSettings: .init(
            id: .init(),
            createdDate: .now,
            isTrackingWorkout: false,
            isWinByTwo: true,
            name: "test",
            scoreLimit: 11,
            serveInterval: 2
        )
    )
    var matchControllerState: MatchControllerState = .init()
    @BindableState public var tabIndex: Int = 2
    var workoutState: WorkoutState? = .init()
}

public enum ActiveMatchTabAction: BindableAction {
    case binding(BindingAction<ActiveMatchTabState>)
    case workout(WorkoutAction)
    case activeMatch(ActiveMatchAction)
    case matchController(MatchControllerAction)
}

public struct ActiveMatchTabEnvironment {
    var healthKitClient: HealthKitClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

private let reducer = ActiveMatchTabReducer
{ state, action, environment in
    switch action {
    case .matchController(.pauseTapped):
        if state.matchControllerState.isPaused {
            // Pause Rally and pause workout
            return .merge(
                Effect(value: .workout(.pause)),
                Effect(value: .activeMatch(.rally(.statusChanged(.paused))))
            )
        } else {
            return .merge(
                Effect(value: .workout(.resume)),
                Effect(value: .activeMatch(.rally(.statusChanged(.active))))
            )
        }
        
    case .matchController(.matchCancelled):
        return Effect(value: .workout(.cancelWorkout))
        
    default:
        return .none
    }
}
.binding()

public let activeMatchTabReducer: ActiveMatchTabReducer =
.combine(
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
