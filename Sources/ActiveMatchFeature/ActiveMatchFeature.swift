import ComposableArchitecture
import ComposableHelpers
import SwiftUI

public typealias ActiveMatchReducer = Reducer<ActiveMatchState, ActiveMatchAction, ActiveMatchEnvironment>

public struct ActiveMatchState: Equatable {
    
    public init() {}
    
    static let teamA = RallyTeam(id: "teamA", teamName: "teamA")
    static let teamB = RallyTeam(id: "teamB", teamName: "teamB")
    
    var rallyGameState = RallyState(
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
            isWinByTwo: true,
            scoreLimit: 11,
            serveInterval: .two,
            teams: [
                teamA,
                teamB
            ]
        )
    )
}

public enum ActiveMatchAction {
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
    
    public var body: some View {
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
                    HStack {
                        HStack {
                            Circle()
                                .frame(width: 5, height: 5)
                                .foregroundColor(
                                    viewStore.rallyGameState.serveState.servingTeam.id == "teamA"
                                    ? .green
                                    : .clear
                                )
                            Text("\(viewStore.rallyGameState.score["teamA"] ?? 0)")
                        }
                        Text("-")
                        HStack {
                            Text("\(viewStore.rallyGameState.score["teamB"] ?? 0 )")
                            Circle()
                                .frame(width: 5, height: 5)
                                .foregroundColor(
                                    viewStore.rallyGameState.serveState.servingTeam.id == "teamB"
                                    ? .green
                                    : .clear
                                )
                        }
                    }
                    .font(.title)
                    Spacer()
                }
                
                Spacer()
                
                Button("Player 1") {
                    viewStore.send(.rally(.teamScored("teamA")))
                }
                Button("Player 2") {
                    viewStore.send(.rally(.teamScored("teamB")))
                }
                
                Button("Cancel", action: { })
                .buttonStyle(BorderedButtonStyle(tint: .red))
                .padding(.top, 24)
            }
        }
    }
}

struct ActiveMatch_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ActiveMatchView(
                store: Store(
                    initialState: .init(),
                    reducer: activeMatchReducer,
                    environment: .init()
                )
            )
        }
    }
}
