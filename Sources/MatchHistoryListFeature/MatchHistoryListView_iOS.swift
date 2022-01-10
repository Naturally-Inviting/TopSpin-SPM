#if os(iOS)
import ComposableArchitecture
import Models
import SwiftUI

struct MatchHistoryListView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let store: Store<MatchHistoryState, MatchHistoryAction>
    @ObservedObject var viewStore: ViewStore<MatchHistoryState, MatchHistoryAction>

    public init(
        store: Store<MatchHistoryState, MatchHistoryAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var backgroundColor: Color {
        return colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground)
    }
    
    var matchHistoryList: some View {
        ForEach(viewStore.matches) { match in
            MatchHistoryItem(match: match)
                .contextMenu {
                    Button(action: { viewStore.send(.deleteButtonTapped(match)) }){
                        Label("Delete", systemImage: "trash")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.vertical, 6)
        }
    }
    
    var historyListView: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView {
                    // TODO: Horizontal Summary Feature
                    
                    if horizontalSize != .regular {
                        LazyVStack(spacing: 0) {
                            matchHistoryList
                        }
                    } else {
                        LazyVGrid(columns: columns, spacing: 20) {
                            matchHistoryList
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if viewStore.matches.isEmpty {
                HistoryEmptyView()
            } else {
                historyListView
            }
        }
        .navigationTitle("Match History")
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
                            isMatchRequestInFlight: false,
                            isDeleteMatchRequestInFlight: false
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
                Text("Needed for iPad")
                
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
                            isMatchRequestInFlight: false,
                            isDeleteMatchRequestInFlight: false
                        ),
                        reducer: matchHistoryReducer,
                        environment: MatchHistoryEnvironment(
                            mainQueue: .main
                        )
                    )
                )
            }
            .previewDevice("iPad mini (6th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
#endif
