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

public struct MatchSeriesState: Equatable {
    struct ButtonState: Equatable {
        var title: String
        var color: Color
    }
    
    init(
        matchSeriesState: RallyMatchState,
        buttonState: [RallyTeam.ID: ButtonState]
    ) {
        self.matchSeriesState = matchSeriesState
        self.buttonState = buttonState
    }
    
    var matchSeriesState: RallyMatchState
    var buttonState: [RallyTeam.ID: ButtonState]
}

extension MatchSeriesState {
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
            matchSettings: .init(
                matchCount: matchCount,
                matchSettings: rallyGameSettings
            )
        )
        
        self.buttonState = [
            teamA.id: .init(title: "POINT", color: .primary),
            teamB.id: .init(title: "POINT", color: .primary)
        ]
    }
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
        
        if case let .matchPoint(team) = state.matchSeriesState.matchStatus {
            state.buttonState[team] = .init(title: "MATCH", color: .green)
        } else if case let .gamePoint(team) = state.matchSeriesState.currentMatch.gameState {
            state.buttonState[team] = .init(title: "GAME", color: .green)
        } else {
            state.matchSeriesState.matchSettings.matchSettings.teams.forEach {
                state.buttonState[$0.id] = .init(title: "POINT", color: .primary)
            }
        }
        
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
                        .buttonStyle(BorderedButtonStyle(tint: viewStore.buttonState[team.id]?.color ?? .primary))
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
    
    static let teamA: RallyTeam = .init(id: "TeamA", teamName: "You")
    static let teamB: RallyTeam = .init(id: "TeamB", teamName: "OPPT.")
    
    static var previews: some View {
        RallyMatchSeriesView(
            store: Store(
                initialState: .init(
                    matchSeriesState: .init(
                        currentMatchIndex: 0,
                        matches: [
                            RallyState(
                                serveState: .init(servingTeam: teamA),
                                score: [teamA.id: 0, teamB.id: 0],
                                gameState: .ready,
                                gameSettings: .init(
                                    isWinByTwo: true,
                                    scoreLimit: 11,
                                    serveInterval: .two,
                                    teams: [
                                        teamA,
                                        teamB
                                    ]
                                )
                            ),
                            RallyState(
                                serveState: .init(servingTeam: teamB),
                                score: [teamA.id: 0, teamB.id: 0],
                                gameState: .ready,
                                gameSettings: .init(
                                    isWinByTwo: true,
                                    scoreLimit: 11,
                                    serveInterval: .two,
                                    teams: [
                                        teamA,
                                        teamB
                                    ]
                                )
                            ),
                            RallyState(
                                serveState: .init(servingTeam: teamA),
                                score: [teamA.id: 0, teamB.id: 0],
                                gameState: .ready,
                                gameSettings: .init(
                                    isWinByTwo: true,
                                    scoreLimit: 11,
                                    serveInterval: .two,
                                    teams: [
                                        teamA,
                                        teamB
                                    ]
                                )
                            )
                        ],
                        isMatchPoint: false,
                        matchStatus: .active,
                        winningTeam: nil,
                        matchSettings: .init(
                            matchCount: 3,
                            matchSettings: .init(
                                isWinByTwo: true,
                                scoreLimit: 11,
                                serveInterval: .two,
                                teams: [
                                    teamA,
                                    teamB
                                ]
                            )
                        )
                    ),
                    buttonState: [
                        teamA.id: .init(title: "POINT", color: .primary),
                        teamB.id: .init(title: "POINT", color: .primary)
                    ]
                ),
                reducer: matchSeriesReducer,
                environment: MatchSeriesEnvironment()
            )
        )
    }
}
