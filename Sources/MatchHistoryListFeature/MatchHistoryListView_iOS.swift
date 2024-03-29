#if os(iOS)
import AddMatchFeature
import ComposableArchitecture
import MatchSummaryDetailFeature
import Models
import MonthlySummaryListFeature
import SwiftUI

public struct MatchHistoryListView: View {
    
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
            NavigationLink(
                destination: IfLetStore(
                    self.store.scope(
                        state: \.selectedMatch?.value
                    ),
                    then: { MatchSummaryDetailView(store: $0.actionless) }
                ),
                tag: match.id,
                selection: viewStore.binding(
                    get: \.selectedMatch?.id,
                    send: MatchHistoryAction.setSelectedMatch(selection:)
                )
            ) {
                MatchHistoryItem(match: match)
                    .contextMenu {
                        Button(action: { viewStore.send(.deleteButtonTapped(match)) }){
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    var historyListView: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView {                    
                    HorizontalMonthlySummaryView(
                        store: store.scope(
                            state: \.monthlySummaryState,
                            action: MatchHistoryAction.monthlySummary
                        )
                    )
                    
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
    
    public var body: some View {
        VStack {
            if viewStore.matches.isEmpty {
                HistoryEmptyView(
                    isConnected: viewStore.isWatchAppInstalled,
                    isWCSessionSupported: viewStore.isWCSessionSupported
                )
            } else {
                historyListView
            }
        }
        .navigationTitle("Match History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewStore.send(.set(\.$isAddMatchNavigationActive, true)) }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: viewStore.binding(\.$isAddMatchNavigationActive)) {
            NavigationView {
                AddMatchView(
                    store: store.scope(
                        state: \.addMatchState,
                        action: MatchHistoryAction.addMatch
                    )
                )
            }
        }
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
                            isWatchAppInstalled: false,
                            isWCSessionSupported: true,
                            isMatchRequestInFlight: false,
                            isDeleteMatchRequestInFlight: false
                        ),
                        reducer: matchHistoryReducer,
                        environment: .mocked
                    )
                )
            }
            .previewDevice("iPad mini (6th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
#endif
