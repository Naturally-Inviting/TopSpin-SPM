import ComposableArchitecture
import Foundation
import Models

public typealias MatchHistoryReducer = Reducer<MatchHistoryState, MatchHistoryAction, MatchHistoryEnvironment>

public struct MatchHistoryState: Equatable {
    public init(
        matches: IdentifiedArrayOf<Match>,
        selectedMatch: Identified<Match.ID, Match>?,
        isMatchRequestInFlight: Bool,
        isDeleteMatchRequestInFlight: Bool
    ) {
        self.matches = matches
        self.selectedMatch =  selectedMatch
        self.isMatchRequestInFlight = isMatchRequestInFlight
        self.isDeleteMatchRequestInFlight = isDeleteMatchRequestInFlight
    }
    
    public var matches: IdentifiedArrayOf<Match>
    public var selectedMatch: Identified<Match.ID, Match>?
    public var isMatchRequestInFlight: Bool
    public var isDeleteMatchRequestInFlight: Bool
}

public enum MatchHistoryAction: Equatable {
    case deleteButtonTapped(Match)
    case setSelectedMatch(selection: Match?)
    case viewLoaded
    case matchesResponse(Result<[Match], MatchClient.Failure>)
    case deleteMatchResponse(Result<[Match], MatchClient.Failure>)
}

public struct MatchClient {
    public struct Failure: Error, Equatable {
        public init() {}
    }
}

public struct MatchHistoryEnvironment {
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.mainQueue = mainQueue
    }
    
    public var mainQueue: AnySchedulerOf<DispatchQueue>
}

public let matchHistoryReducer = MatchHistoryReducer
{ state, action, environment in
    switch action {
    case let .matchesResponse(.failure(error)):
        return .none
        
    case let .matchesResponse(.success(matches)):
        state.isMatchRequestInFlight = false
        state.matches = IdentifiedArrayOf<Match>(uniqueElements: matches)
        return .none
        
    case let .setSelectedMatch(selection: .some(match)):
        if let match = state.matches[id: match.id] {
            state.selectedMatch = Identified(
                match,
                id: match.id
            )
        }
        
        return .none
        
    case .setSelectedMatch(selection: .none):
        if let selectionState = state.selectedMatch {
            state.matches[id: selectionState.id] = selectionState.value
        }

        state.selectedMatch = nil
        return .none
        
    case .viewLoaded:
        state.isMatchRequestInFlight = true
        return .none
        
    case let .deleteButtonTapped(match):
        state.isDeleteMatchRequestInFlight = true
        return .none
        
    case let .deleteMatchResponse(.failure(error)):
        return .none
        
    case let .deleteMatchResponse(.success(matches)):
        state.isDeleteMatchRequestInFlight = true
        state.matches = IdentifiedArrayOf<Match>(uniqueElements: matches)
        return .none

    }
}
