import ComposableArchitecture
import ComposableHelpers
import Models
import Rally
import SwiftUI
import World

public typealias MatchSeriesReducer = Reducer<
    MatchSeriesState,
    MatchSeriesAction,
    MatchSeriesEnvironment
>

extension RallyState: Identifiable {
    public var id: UUID {
        return Current.uuid()
    }
}

extension RallyTeam: Identifiable {}

struct ButtonState: Equatable {
    var title: String
    var color: Color
}

public struct MatchSeriesState: Equatable {
    
    public init(
        matchCount: Int,
        matchSettings: MatchSetting
    ) {
        // FUTURE: - New Feature
        let teamA = RallyTeam(id: "teamA", teamName: "You")
        let teamB = RallyTeam(id: "teamB", teamName: "Oppnt.")
        
        let rallyGameSettings: RallyEnvironment = .init(
            isWinByTwo: matchSettings.isWinByTwo,
            scoreLimit: matchSettings.scoreLimit,
            serveInterval: .init(rawValue: matchSettings.serveInterval)!,
            teams: [
                teamA,
                teamB
            ]
        )
        
        self.matchEnvironment = .init(
            matchCount: matchCount,
            matchSettings: rallyGameSettings
        )
        
        let matches: [RallyState] = (0..<matchCount).map { matchNumber in
            RallyState(
                serveState: RallyServeState(
                    servingTeam: (matchNumber % 2) == 0 ? teamA : teamB // Alternating
                ),
                score: [
                    teamA.id: 0,
                    teamB.id: 0
                ],
                gameState: .ready,
                gameSettings: rallyGameSettings
            )
        }
        
        self.matchSeriesState = .init(
            currentMatchIndex: 0,
            matches: matches,
            isMatchPoint: false,
            matchStatus: .active,
            winningTeam: nil,
            matchSettings: self.matchEnvironment
        )
        
        self.buttonState = [
            teamA.id: .init(title: "POINT", color: .primary),
            teamB.id: .init(title: "POINT", color: .primary)
        ]
    }
    
    var matchEnvironment: RallyMatchEnvironment
    var matchSeriesState: RallyMatchState
    
    var buttonState: [RallyTeam.ID: ButtonState]
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
                        
                        Button(viewStore.buttonState[team.id]?.title ?? "") {
                            viewStore.send(.rally(.gameAction(.teamScored(team.id))))
                        }
                        .padding(4)
                        .buttonStyle(BorderedButtonStyle(tint: viewStore.buttonState[team.id]?.color ?? .clear))
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
                initialState: MatchSeriesState(
                    matchCount: 5,
                    matchSettings: .init(
                        id: .init(),
                        createdDate: .now,
                        isTrackingWorkout: true,
                        isWinByTwo: true,
                        name: "test",
                        scoreLimit: 11,
                        serveInterval: 2
                    )
                ),
                reducer: matchSeriesReducer,
                environment: MatchSeriesEnvironment()
            )
        )
    }
}
