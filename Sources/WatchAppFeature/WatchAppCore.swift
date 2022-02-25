import ActiveMatchFeature
import ComposableArchitecture
import HealthKitClient
import SwiftUI
import WatchConnectivityClient
import WorkoutFeature

public typealias WatchCoreReducer = Reducer<WatchAppState, WatchAppAction, WatchEnvironment>

public struct WatchAppState: Equatable {
    public init(
        selectedTabIndex: Int = 2,
        watchConnectivityState: WatchConnectivityState = .init(),
        workoutState: WorkoutState = .init()
    ) {
        self.selectedTabIndex = selectedTabIndex
        self.watchConnectivityState = watchConnectivityState
        self.workoutState = workoutState
    }
    
    @BindableState public var selectedTabIndex: Int
    public var watchConnectivityState: WatchConnectivityState
    public var workoutState: WorkoutState
    public var activeMatchState: ActiveMatchState? = .init(
        matchSettings: .init(
            id: .init(),
            createdDate: .now,
            isTrackingWorkout: true,
            isWinByTwo: true,
            name: "test",
            scoreLimit: 11,
            serveInterval: 2
        )
    )
}

public enum WatchAppAction: BindableAction {
    case binding(BindingAction<WatchAppState>)
    case scenePhaseChanged(ScenePhase)
    // Watch Connectivity
    case setWatchAppInstalled(Bool)
    case setWCSessionSupported(Bool)
    case watchConnectivity(Result<WatchConnectivityClient.Action, WatchConnectivityClient.Failure>)
    
    case workout(WorkoutAction)
    case activeMatch(ActiveMatchAction)
}

public struct WatchEnvironment {
    public init(
        healthKitClient: HealthKitClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        watchConnectivityClient: WatchConnectivityClient
    ) {
        self.healthKitClient = healthKitClient
        self.mainQueue = mainQueue
        self.watchConnectivityClient = watchConnectivityClient
    }
    
    var healthKitClient: HealthKitClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var watchConnectivityClient: WatchConnectivityClient
}

extension WatchEnvironment {
    public static var live: Self {
        Self(
            healthKitClient: .live,
            mainQueue: .main,
            watchConnectivityClient: .live
        )
    }
}

private let reducer = WatchCoreReducer
{ state, action, environment in
    struct WatchConnectivityId: Hashable {}

    switch action {
    case let .setWCSessionSupported(isSupported):
        state.watchConnectivityState.isWCSessionSupported = isSupported
        return .none
        
    case let .setWatchAppInstalled(isInstalled):
        state.watchConnectivityState.isWatchAppInstalled = isInstalled
        return .none
        
    case let .watchConnectivity(.success(.activationDidComplete(state, error))):
        guard error == nil, state == .activated
        else { return .none } // TODO: - Handle Error
    
        return .merge(
            environment.watchConnectivityClient.isWatchAppInstalled(WatchConnectivityId())
                .map(WatchAppAction.setWatchAppInstalled)
                .eraseToEffect(),
            environment.watchConnectivityClient.isWCSessionSupported()
                .map(WatchAppAction.setWCSessionSupported)
                .eraseToEffect()
        )
        
    case .scenePhaseChanged(.active):
        return environment.watchConnectivityClient.activate(WatchConnectivityId())
            .receive(on: environment.mainQueue)
            .catchToEffect(WatchAppAction.watchConnectivity)
        
    default:
        return .none
    }
}
.binding()

public let watchCoreReducer: WatchCoreReducer =
.combine(
    workoutReducer
        .pullback(
            state: \.workoutState,
            action: /WatchAppAction.workout,
            environment: {
                WorkoutEnvironment(
                    healthKitClient: $0.healthKitClient,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    activeMatchReducer
        .optional()
        .pullback(
            state: \.activeMatchState,
            action: /WatchAppAction.activeMatch,
            environment: { _ in 
                ActiveMatchEnvironment()
            }
        ),
    reducer
)
