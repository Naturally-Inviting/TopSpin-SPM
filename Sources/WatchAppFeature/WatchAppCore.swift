import ComposableArchitecture
import WatchConnectivityClient
import SwiftUI

public typealias AppCoreReducer = Reducer<WatchAppState, WatchAppAction, WatchEnvironment>

public struct WatchAppState: Equatable {
    public init(
        selectedTabIndex: Int = 2,
        watchConnectivityState: WatchConnectivityState = .init()
    ) {
        self.selectedTabIndex = selectedTabIndex
        self.watchConnectivityState = watchConnectivityState
    }
    
    @BindableState public var selectedTabIndex: Int
    public var watchConnectivityState: WatchConnectivityState
}

public enum WatchAppAction: BindableAction {
    case binding(BindingAction<WatchAppState>)
    case scenePhaseChanged(ScenePhase)
    // Watch Connectivity
    case setWatchAppInstalled(Bool)
    case setWCSessionSupported(Bool)
    case watchConnectivity(Result<WatchConnectivityClient.Action, WatchConnectivityClient.Failure>)
}

public struct WatchEnvironment {
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        watchConnectivityClient: WatchConnectivityClient
    ) {
        self.mainQueue = mainQueue
        self.watchConnectivityClient = watchConnectivityClient
    }
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var watchConnectivityClient: WatchConnectivityClient
}

extension WatchEnvironment {
    public static var live: Self {
        Self(
            mainQueue: .main,
            watchConnectivityClient: .live
        )
    }
}

public let watchAppCoreReducer = AppCoreReducer
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
