import ComposableArchitecture
import ComposableHelpers
import Rally
import SwiftUI

public typealias MatchSeriesReducer = Reducer<MatchSeriesState, MatchSeriesAction, MatchSeriesEnvironment>

extension RallyState: Identifiable {
    public var id: UUID {
        return UUID()
    }
}

extension RallyTeam: Identifiable {}

public struct MatchSeriesState: Equatable {
    
    public init() {}
    
    static let teamA = RallyTeam(id: "teamA", teamName: "teamA")
    static let teamB = RallyTeam(id: "teamB", teamName: "teamB")
    static let matchSettings = RallyMatchEnvironment(
        matchCount: 3,
        matchSettings: .init(
            isWinByTwo: true,
            scoreLimit: 11,
            serveInterval: .two,
            teams: [teamA, teamB]
        )
    )
    
    var matchSeriesState: RallyMatchState = .init(
        matches: [
            .init(
                serveState: .init(servingTeam: teamA),
                score: [teamA.id: 0, teamB.id: 0],
                gameState: .ready,
                gameSettings: matchSettings.matchSettings
            ),
            .init(
                serveState: .init(servingTeam: teamB),
                score: [teamA.id: 0, teamB.id: 0],
                gameState: .ready,
                gameSettings: matchSettings.matchSettings
            ),
            .init(
                serveState: .init(servingTeam: teamA),
                score: [teamA.id: 0, teamB.id: 0],
                gameState: .ready,
                gameSettings: matchSettings.matchSettings
            )
        ],
        matchSettings: matchSettings
    )
}

public enum MatchSeriesAction {
    case rally(RallyMatchAction)
    case viewLoaded
}

public struct MatchSeriesEnvironment {
    public init() {}
}

public let matchSeriesReducer = MatchSeriesReducer
{ state, action, environment in
    switch action {
    case let .rally(rallyAction):
        state.matchSeriesState = rallyMatchReducer(state.matchSeriesState, rallyAction)
        return .none
        
    default:
        return .none
    }
}

struct RallyMatchSeriesView: View {
   
    let store: Store<MatchSeriesState, MatchSeriesAction>
    @ObservedObject var viewStore: ViewStore<MatchSeriesState, MatchSeriesAction>
    
    public init(
        store: Store<MatchSeriesState, MatchSeriesAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var matches: [RallyState] {
        return viewStore.matchSeriesState.matches
    }
    
    var gameState: RallyState {
        return viewStore.matchSeriesState.currentMatch
    }
    
    var body: some View {
        ScrollView {
            VStack {
                
                HStack {
                    ForEach(matches) { match in
                        if let winningTeam = match.winningTeam,
                           let firstServingTeam = matches.first?.gameSettings.teams.first {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(winningTeam == firstServingTeam ? .green : .red)
                        } else {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding()
 
            HStack(spacing: 0) {
                ForEach(gameState.gameSettings.teams) { team in
                    VStack {
                        Text(team.teamName)
                        Text("\(gameState.score[team.id] ?? 0)")
                            .font(.largeTitle)

                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(team == gameState.serveState.servingTeam ? .green : .clear)
                        
                        if viewStore.matchSeriesState.currentMatch.isGamePoint
                            && viewStore.matchSeriesState.currentMatch.winningTeam == team {
                            
                            Button("GAME") {
                                viewStore.send(.rally(.gameAction(.teamScored(team.id))))
                            }
                            .padding(4)
                            .buttonStyle(BorderedButtonStyle(tint: .green))
                            
                        } else if viewStore.matchSeriesState.isMatchPoint
                                    && viewStore.matchSeriesState.currentMatch.winningTeam == team {
                            Button("MATCH") {
                                viewStore.send(.rally(.gameAction(.teamScored(team.id))))
                            }
                            .padding(4)
                            .buttonStyle(BorderedButtonStyle(tint: .green))
                            
                        } else {
                            Button("POINT") {
                                viewStore.send(.rally(.gameAction(.teamScored(team.id))))
                            }
                            .padding(4)
                        }
                        
                    }
                }
            }
            
            Spacer()
            
            Button("Cancel", action: { viewStore.send(.rally(.gameAction(.statusChanged(.cancelled)))) })
                .buttonStyle(BorderedButtonStyle(tint: .red))
                .padding(.top, 24)
        }
        .navigationTitle("Match")
    }
}

struct RallyMatchSeriesView_Previews: PreviewProvider {
    
    static var previews: some View {
        RallyMatchSeriesView(
            store: Store(
                initialState: MatchSeriesState(),
                reducer: matchSeriesReducer,
                environment: MatchSeriesEnvironment()
            )
        )
    }
}
