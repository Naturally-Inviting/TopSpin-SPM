import ComposableArchitecture
import Foundation
import MatchClient
import MatchHistoryListFeature

public typealias AppCoreReducer = Reducer<AppCoreState, AppCoreAction, AppCoreEnvironment>

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
    case matchHistory(MatchHistoryAction)
    case binding(BindingAction<AppCoreState>)
}

public struct AppCoreEnvironment {
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

private let reducer = AppCoreReducer
{ state, action, environment in
    switch action {
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
