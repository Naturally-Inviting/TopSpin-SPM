import ComposableArchitecture
import ComposableHelpers
import Models
import Rally
import SwiftUI

public typealias ActiveMatchReducer = Reducer<ActiveMatchState, ActiveMatchAction, ActiveMatchEnvironment>

extension RallyTeam: Identifiable {}

public struct ActiveMatchState: Equatable {
    
    struct ButtonState: Equatable {
        var title: String
        var color: Color
    }

    init(
        rallyGameState: RallyState,
        buttonState: [RallyTeam.ID: ButtonState]
    ) {
        self.rallyGameState = rallyGameState
        self.buttonState = buttonState
    }
    
    var rallyGameState: RallyState
    var buttonState: [RallyTeam.ID: ButtonState]
}

public extension ActiveMatchState {
    init(
        matchSettings: MatchSetting
    ) {
        let teamA = RallyTeam(id: "teamA", teamName: "You")
        let teamB = RallyTeam(id: "teamB", teamName: "Oppt.")
        
        rallyGameState = RallyState(
            serveState:  RallyServeState(servingTeam: teamA),
            score: [
                teamA.id: 0,
                teamB.id: 0
            ],
            gameState: .ready,
            gameLog: [],
            isGamePoint: false,
            winningTeam: nil,
            gameSettings: .init(
                isWinByTwo: matchSettings.isWinByTwo,
                scoreLimit: matchSettings.scoreLimit,
                serveInterval: .init(rawValue: matchSettings.serveInterval)!,
                teams: [
                    teamA,
                    teamB
                ]
            )
        )
        
        self.buttonState = [
            teamA.id: .init(title: "POINT", color: .primary),
            teamB.id: .init(title: "POINT", color: .primary)
        ]
    }
}

public enum ActiveMatchAction {
    case cancel
    case rally(RallyAction)
}

public struct ActiveMatchEnvironment {
    public init() {}
}

public let activeMatchReducer = ActiveMatchReducer
{ state, action, environment in
    switch action {
    case let .rally(rallyAction):
        state.rallyGameState = rallyGameReducer(state.rallyGameState, rallyAction)
        
        if case let .gamePoint(team) = state.rallyGameState.gameState {
            state.buttonState[team] = .init(title: "GAME", color: .green)
        } else {
            state.rallyGameState.gameSettings.teams.forEach {
                state.buttonState[$0.id] = .init(title: "POINT", color: .primary)
            }
        }
        
        return .none
        
    default:
        return .none
    }
}

public struct ActiveMatchView: View {
    let store: Store<ActiveMatchState, ActiveMatchAction>
    @ObservedObject var viewStore: ViewStore<ActiveMatchState, ActiveMatchAction>
    
    public init(
        store: Store<ActiveMatchState, ActiveMatchAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var matchReadyView: some View {
        Button("Start Game", action: { viewStore.send(.rally(.statusChanged(.active))) })
    }
    
    var matchActiveView: some View {
        ScrollView {
            VStack {
                if viewStore.rallyGameState.isGamePoint {
                    Text("GAME POINT")
                        .font(.caption2)
                        .bold()
                        .padding(2)
                        .background(Color.orange)
                        .cornerRadius(2)
                }
                
                HStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(viewStore.rallyGameState.gameSettings.teams) { team in
                            VStack {
                                Text(team.teamName)
                                Text("\(viewStore.rallyGameState.score[team.id] ?? 0)")
                                    .font(.largeTitle)

                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(team == viewStore.rallyGameState.serveState.servingTeam ? .green : .clear)
                                
                                Button(viewStore.buttonState[team.id]?.title ?? "hi") {
                                    viewStore.send(.rally(.teamScored(team.id)))
                                }
                                .padding(4)
                                .buttonStyle(BorderedButtonStyle(
                                    tint: viewStore.buttonState[team.id]?.color ?? .primary)
                                )
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                Button("Cancel", action: { })
                    .buttonStyle(BorderedButtonStyle(tint: .red))
                    .padding(.top, 24)
            }
        }
    }
    
    var matchCompleteView: some View {
        Text("Match Over!")
    }
    
    public var body: some View {
        if viewStore.rallyGameState.gameState == .ready {
            matchReadyView
        } else if viewStore.rallyGameState.gameState == .complete {
            matchCompleteView
        } else {
            matchActiveView
        }
    }
}

struct ActiveMatch_Previews: PreviewProvider {
    static let teamA: RallyTeam = .init(id: "TeamA", teamName: "You")
    static let teamB: RallyTeam = .init(id: "TeamB", teamName: "OPPT.")

    static var previews: some View {
        NavigationView {
            ActiveMatchView(
                store: Store(
                    initialState: .init(
                        rallyGameState: .init(
                            serveState: .init(servingTeam: teamA),
                            score: [
                                teamA.id: 0,
                                teamB.id: 0
                            ],
                            gameState: .ready,
                            gameLog: [],
                            isGamePoint: false,
                            winningTeam: nil,
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
                        buttonState: [
                            teamA.id: .init(title: "POINT", color: .primary),
                            teamB.id: .init(title: "POINT", color: .primary)
                        ]
                    ),
                    reducer: activeMatchReducer,
                    environment: .init()
                )
            )
        }
    }
}
