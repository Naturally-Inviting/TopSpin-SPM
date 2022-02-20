import ComposableArchitecture
import Models
import SwiftUI

public struct MatchSummaryState: Equatable {
    public init(
        match: Match
    ) {
        self.match = match
    }
    
    public var match: Match
}

public struct MatchSummaryDetailView: View {
    let store: Store<MatchSummaryState, Never>
    @ObservedObject var viewStore: ViewStore<MatchSummaryState, Never>
    
    public init(
        store: Store<MatchSummaryState, Never>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        MatchSummaryView(match: viewStore.match)
    }
}

public struct MatchSummaryEnvironment {
    public init() {}
}
