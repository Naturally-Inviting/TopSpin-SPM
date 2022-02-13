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
}

public struct AppCoreState: Equatable {
    public init(
        matchHistoryState: MatchHistoryState = MatchHistoryState(),
        selectedTabIndex: Int = 0,
        isMatchHistoryNavigationActive: Bool = false,
        isSettingsNavigationActive: Bool = false
    ) {
        self.matchHistoryState = matchHistoryState
        self.selectedTabIndex = selectedTabIndex
        self.isMatchHistoryNavigationActive = isMatchHistoryNavigationActive
        self.isSettingsNavigationActive = isSettingsNavigationActive
    }
    
    public var matchHistoryState: MatchHistoryState
    @BindableState public var selectedTabIndex: Int
    @BindableState public var isMatchHistoryNavigationActive: Bool
    @BindableState public var isSettingsNavigationActive: Bool
}

public enum AppCoreAction: BindableAction {
    case binding(BindingAction<AppCoreState>)
    case didChangeScenePhase(scenePhase: ScenePhase)
    case matchHistory(MatchHistoryAction)
    
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
//    case let .watchConnectivity(.success(.activationDidComplete(state, error))):
//        print(state)
//        print(error)
//        
//        return .none
        
    case .didChangeScenePhase(scenePhase: .active):
        
        return environment.watchConnectivityClient.activate(WatchConnectivityId())
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
