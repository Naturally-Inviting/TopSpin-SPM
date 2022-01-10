#if os(watchOS)
import ComposableArchitecture
import Models
import SwiftUI

struct MatchHistoryListView: View {
    
    let store: Store<MatchHistoryState, MatchHistoryAction>
    @ObservedObject var viewStore: ViewStore<MatchHistoryState, MatchHistoryAction>

    public init(
        store: Store<MatchHistoryState, MatchHistoryAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    

    var body: some View {
        if viewStore.matches.isEmpty {
            HistoryEmptyView()
        } else {
            List {
                ForEach(viewStore.matches) { match in
                    MatchHistoryItem(match: match)
                }
            }
            .navigationTitle("Match History")
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
                                        averageHeartRate: 120,
                                        maxHeartRate: 132,
                                        minHeartRate: 110
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
                                        averageHeartRate: 120,
                                        maxHeartRate: 132,
                                        minHeartRate: 110
                                    )
                                )
                            ]
                        ),
                        reducer: matchHistoryReducer,
                        environment: MatchHistoryEnvironment(
                            mainQueue: .main
                        )
                    )
                )
            }
            .preferredColorScheme(.dark)
            
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
                                        averageHeartRate: 120,
                                        maxHeartRate: 132,
                                        minHeartRate: 110
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
                                        averageHeartRate: 120,
                                        maxHeartRate: 132,
                                        minHeartRate: 110
                                    )
                                )
                            ]
                        ),
                        reducer: matchHistoryReducer,
                        environment: MatchHistoryEnvironment(
                            mainQueue: .main
                        )
                    )
                )
            }
        }
    }
}
#endif
