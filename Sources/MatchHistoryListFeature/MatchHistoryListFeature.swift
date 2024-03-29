import AddMatchFeature
import ComposableArchitecture
import Foundation
import MatchClient
import MatchSummaryDetailFeature
import Models
import MonthlySummaryListFeature

public typealias MatchHistoryReducer = Reducer<MatchHistoryState, MatchHistoryAction, MatchHistoryEnvironment>

public struct MatchHistoryState: Equatable {
    public init(
        matches: IdentifiedArrayOf<Match> = [],
        selectedMatch: Identified<Match.ID, MatchSummaryState>? = nil,
        isWatchAppInstalled: Bool = false,
        isWCSessionSupported: Bool = false,
        isMatchRequestInFlight: Bool = false,
        isDeleteMatchRequestInFlight: Bool = false,
        addMatchState: AddMatchState = .init(),
        monthlySummaryState: MonthlySummaryState = .init(),
        isAddMatchNavigationActive: Bool = false
    ) {
        self.matches = matches
        self.selectedMatch =  selectedMatch
        self.isWatchAppInstalled = isWatchAppInstalled
        self.isWCSessionSupported = isWCSessionSupported
        self.isMatchRequestInFlight = isMatchRequestInFlight
        self.isDeleteMatchRequestInFlight = isDeleteMatchRequestInFlight
        self.addMatchState = addMatchState
        self.monthlySummaryState = monthlySummaryState
        self.isAddMatchNavigationActive = isAddMatchNavigationActive
    }
    
    public var matches: IdentifiedArrayOf<Match>
    public var selectedMatch: Identified<Match.ID, MatchSummaryState>?
    public var isWatchAppInstalled: Bool
    public var isWCSessionSupported: Bool
    public var isMatchRequestInFlight: Bool
    public var isDeleteMatchRequestInFlight: Bool
    public var addMatchState: AddMatchState
    public var monthlySummaryState: MonthlySummaryState
    @BindableState public var isAddMatchNavigationActive: Bool = false
}

public enum MatchHistoryAction: Equatable, BindableAction {
    case binding(BindingAction<MatchHistoryState>)
    case deleteButtonTapped(Match)
    case setSelectedMatch(selection: UUID?)
    case viewLoaded
    case matchesResponse(Result<[Match], MatchClient.Failure>)
    case openWatchSettingsTapped
    case addMatch(AddMatchAction)
    case monthlySummary(MonthlySummaryAction)
}

public struct MatchHistoryEnvironment {
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        matchClient: MatchClient = .live
    ) {
        self.mainQueue = mainQueue
        self.matchClient = matchClient
    }
    
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var matchClient: MatchClient
}

public let matchHistoryReducer: MatchHistoryReducer =
.combine(
    addMatchReducer
        .pullback(
            state: \.addMatchState,
            action: /MatchHistoryAction.addMatch,
            environment: {
                AddMatchEnvironment(
                    mainQueue: $0.mainQueue,
                    matchClient: $0.matchClient
                )
            }
        ),
    monthlySummaryReducer
        .pullback(
            state: \.monthlySummaryState,
            action: /MatchHistoryAction.monthlySummary,
            environment: { _ in .init() }
        ),
    reducer
)

private let reducer = MatchHistoryReducer
{ state, action, environment in
    switch action {
    
    case let .matchesResponse(.failure(error)):
        return .none
        
    case let .matchesResponse(.success(matches)):
        state.isMatchRequestInFlight = false
        state.matches = IdentifiedArrayOf<Match>(uniqueElements: matches)
        state.monthlySummaryState = MonthlySummaryState(matches: matches)
        return .none
        
    case let .setSelectedMatch(selection: .some(id)):
        if let match = state.matches[id: id] {
            state.selectedMatch = Identified(
                MatchSummaryState(match: match),
                id: match.id
            )
        }
        
        return .none
        
    case .setSelectedMatch(selection: .none):
        state.selectedMatch = nil
        return .none
        
    case .viewLoaded:
        guard state.matches.isEmpty else { return .none }
        
        state.isMatchRequestInFlight = true
        
        return environment.matchClient.fetch()
            .receive(on: environment.mainQueue)
            .catchToEffect(MatchHistoryAction.matchesResponse)
        
    case let .deleteButtonTapped(match):
        state.isDeleteMatchRequestInFlight = true
        state.matches.removeAll(where: { $0.id == match.id })
        
        return environment.matchClient.delete(match)
            .fireAndForget()
        
    case .openWatchSettingsTapped:
        // TODO: THIS
//        UIApplication.shared.open(URL(string: "itms-watchs://com.willBrandin.dev")!) { (didOpen) in
//            print(didOpen ? "Did open url" : "FAILED TO OPEN")
//        }
        return .none
        
    case let .addMatch(.saveMatchResponse(.success(match))):
        state.matches.append(match)
        state.monthlySummaryState = .init(matches: state.matches.elements)
        state.isAddMatchNavigationActive = false
        return .none
        
    default:
        return .none
    }
}
.binding()

extension MatchHistoryEnvironment {
    static var mocked: Self {
        var matchClient = MatchClient.live
        
        matchClient.fetch = {
            let mocked: [Match] = [
                .init(
                    id: .init(),
                    date: .init(),
                    playerScore: 11,
                    opponentScore: 8,
                    workout: .init(
                        id: .init(),
                        startDate: .distantPast,
                        endDate: .init(),
                        activeCalories: 210,
                        heartRateAverage: 120,
                        heartRateMax: 132,
                        heartRateMin: 110
                    )
                ),
                .init(
                    id: .init(),
                    date: .init(),
                    playerScore: 12,
                    opponentScore: 21,
                    workout: .init(
                        id: .init(),
                        startDate: .distantPast,
                        endDate: .init(),
                        activeCalories: 210,
                        heartRateAverage: 120,
                        heartRateMax: 132,
                        heartRateMin: 110
                    )
                )
            ]
            
            return Effect(value: mocked)
        }

        return Self(mainQueue: .main, matchClient: matchClient)
    }
}
