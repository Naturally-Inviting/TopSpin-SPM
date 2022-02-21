import AppDelegateFeature
import Combine
import ComposableArchitecture
import MatchHistoryListFeature
import SwiftUI
import UserSettingsFeature
import WatchConnectivityClient

public typealias AppCoreReducer = Reducer<AppCoreState, AppCoreAction, AppCoreEnvironment>

public struct AppCoreState: Equatable {
    public init(
        matchHistoryState: MatchHistoryState = MatchHistoryState(),
        userSettingsState: UserSettingsState = UserSettingsState(),
        selectedTabIndex: Int = 0,
        isMatchHistoryNavigationActive: Bool = false,
        isSettingsNavigationActive: Bool = false,
        watchConnectivityState: WatchConnectivityState = .init()
    ) {
        self.matchHistoryState = matchHistoryState
        self.userSettingsState = userSettingsState
        self.selectedTabIndex = selectedTabIndex
        self.isMatchHistoryNavigationActive = isMatchHistoryNavigationActive
        self.isSettingsNavigationActive = isSettingsNavigationActive
        self.watchConnectivityState = watchConnectivityState
    }
    
    public var matchHistoryState: MatchHistoryState
    public var userSettingsState: UserSettingsState
    @BindableState public var selectedTabIndex: Int
    @BindableState public var isMatchHistoryNavigationActive: Bool
    @BindableState public var isSettingsNavigationActive: Bool
    public var watchConnectivityState: WatchConnectivityState
}

public enum AppCoreAction: BindableAction {
    case binding(BindingAction<AppCoreState>)
    case didChangeScenePhase(scenePhase: ScenePhase)
    case matchHistory(MatchHistoryAction)
    case userSettings(UserSettingsAction)
    case appDelegate(AppDelegateAction)

    // Watch Connectivity
    case setWatchAppInstalled(Bool)
    case setWCSessionSupported(Bool)
    case watchConnectivity(Result<WatchConnectivityClient.Action, WatchConnectivityClient.Failure>)
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
        
    case .appDelegate(.didFinishLaunching):
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
    appDelegateReducer
        .pullback(
            state: \.userSettingsState.userSettings,
            action: /AppCoreAction.appDelegate,
            environment: {
                AppDelegateEnvironment(
                    fileClient: $0.fileClient,
                    mainQueue: $0.mainQueue,
                    uiUserInterfaceStyleClient: $0.uiUserInterfaceStyleClient
                )
            }
        ),
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
    userSettingsReducer
        .pullback(
            state: \.userSettingsState,
            action: /AppCoreAction.userSettings,
            environment: {
                UserSettingsEnvironment(
                    cloudKitClient: $0.cloudKitClient,
                    defaultSettingsClient: $0.defaultSettingsClient,
                    emailClient: $0.emailClient,
                    fileClient: $0.fileClient,
                    mainQueue: $0.mainQueue,
                    matchSettingsClient: $0.matchSettingsClient,
                    shareSheetClient: $0.shareSheetClient,
                    storeKitClient: $0.storeKitClient,
                    uiApplicationClient: $0.uiApplicationClient,
                    uiUserInterfaceStyleClient: $0.uiUserInterfaceStyleClient,
                    userDefaults: $0.userDefaults
                )
            }
        ),
    reducer
)
