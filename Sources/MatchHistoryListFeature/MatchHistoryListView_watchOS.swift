#if os(watchOS)
import ComposableArchitecture
import Models
import SwiftUI

public struct MatchHistoryListView: View {
    
    let store: Store<MatchHistoryState, MatchHistoryAction>
    @ObservedObject var viewStore: ViewStore<MatchHistoryState, MatchHistoryAction>

    public init(
        store: Store<MatchHistoryState, MatchHistoryAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    

    public var body: some View {
        VStack {
            if viewStore.matches.isEmpty {
                HistoryEmptyView()
            } else {
                List {
                    ForEach(viewStore.matches) { match in
                        MatchHistoryItem(match: match)
                    }
                }
            }
        }
        .navigationTitle("Match History")
        .onAppear {
            viewStore.send(.viewLoaded)
        }
    }
}

struct MatchHistoryListView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            NavigationView {
                MatchHistoryListView(
                    store: Store(
                        initialState: MatchHistoryState(
                            matches: [
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
                                    playerScore: 21,
                                    opponentScore: 18,
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
                            ],
                            selectedMatch: nil,
                            isWatchAppInstalled: true,
                            isWCSessionSupported: true,
                            isMatchRequestInFlight: false,
                            isDeleteMatchRequestInFlight: false
                        ),
                        reducer: matchHistoryReducer,
                        environment: .mocked
                    )
                )
            }
            .preferredColorScheme(.dark)
            
            NavigationView {
                MatchHistoryListView(
                    store: Store(
                        initialState: MatchHistoryState(
                            matches: [],
                            selectedMatch: nil,
                            isWatchAppInstalled: true,
                            isWCSessionSupported: true,
                            isMatchRequestInFlight: false,
                            isDeleteMatchRequestInFlight: false
                        ),
                        reducer: matchHistoryReducer,
                        environment: .mocked
                    )
                )
            }
        }
    }
}
#endif
