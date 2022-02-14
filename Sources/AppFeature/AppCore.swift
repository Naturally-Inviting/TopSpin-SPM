import Combine
import ComposableArchitecture
import Foundation
import MatchClient
import MatchHistoryListFeature
import SwiftUI

import WatchConnectivityClient

public typealias AppCoreReducer = Reducer<AppCoreState, AppCoreAction, AppCoreEnvironment>

public struct WatchConnectivityState: Equatable {
    public var isWatchAppInstalled = false
    public var isWCSessionSupported = false
    
    public init(
        isWatchAppInstalled: Bool = false,
        isWCSessionSupported: Bool = false
    ) {
        self.isWatchAppInstalled = isWatchAppInstalled
        self.isWCSessionSupported = isWCSessionSupported
    }
}

public struct AppCoreState: Equatable {
    public init(
        matchHistoryState: MatchHistoryState = MatchHistoryState(),
        selectedTabIndex: Int = 0,
        isMatchHistoryNavigationActive: Bool = false,
        isSettingsNavigationActive: Bool = false,
        watchConnectivityState: WatchConnectivityState = .init()
    ) {
        self.matchHistoryState = matchHistoryState
        self.selectedTabIndex = selectedTabIndex
        self.isMatchHistoryNavigationActive = isMatchHistoryNavigationActive
        self.isSettingsNavigationActive = isSettingsNavigationActive
        self.watchConnectivityState = watchConnectivityState
    }
    
    public var matchHistoryState: MatchHistoryState
    @BindableState public var selectedTabIndex: Int
    @BindableState public var isMatchHistoryNavigationActive: Bool
    @BindableState public var isSettingsNavigationActive: Bool
    
    public var watchConnectivityState: WatchConnectivityState
}

public enum AppCoreAction: BindableAction {
    case binding(BindingAction<AppCoreState>)
    case didChangeScenePhase(scenePhase: ScenePhase)
    case matchHistory(MatchHistoryAction)
    
    case setWatchAppInstalled(Bool)
    case setWCSessionSupported(Bool)
    case watchConnectivity(Result<WatchConnectivityClient.Action, WatchConnectivityClient.Failure>)
}

public struct AppCoreEnvironment {
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        matchClient: MatchClient,
        watchConnectivityClient: WatchConnectivityClient
    ) {
        self.mainQueue = mainQueue
        self.matchClient = matchClient
        self.watchConnectivityClient = watchConnectivityClient
    }
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var matchClient: MatchClient
    var watchConnectivityClient: WatchConnectivityClient
}

private let reducer = AppCoreReducer
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
                .map(AppCoreAction.setWatchAppInstalled)
                .eraseToEffect(),
            environment.watchConnectivityClient.isWCSessionSupported()
                .map(AppCoreAction.setWCSessionSupported)
                .eraseToEffect()
        )
        
    case .didChangeScenePhase(scenePhase: .active):
        return environment.watchConnectivityClient.activate(WatchConnectivityId())
            .receive(on: environment.mainQueue)
            .catchToEffect(AppCoreAction.watchConnectivity)
        
    default:
        return .none
    }
}
.binding()

public let appCoreReducer: AppCoreReducer =
.combine(
    matchHistoryReducer
        .pullback(
            state: \.matchHistoryState,
            action: /AppCoreAction.matchHistory,
            environment: {
                MatchHistoryEnvironment(
                    mainQueue: $0.mainQueue,
                    matchClient: $0.matchClient
                )
            }
        ),
    reducer
)
