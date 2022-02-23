import XCTest
@testable import Rally

final class FullRallyGameTest: XCTestCase {
    static var allTests = [
        ("testFullGame", testFullGame),
    ]
    
    func testFullGame() {
        
        Current.date = { .distantFuture }
        Current.uuid = { UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")! }

        var state = RallyState(
            serveState: RallyServeState(servingTeam: RallyTeam.teamA),
            score: [
                RallyTeam.teamA.id: 0,
                RallyTeam.teamB.id: 0
            ],
            gameState: .ready,
            gameLog: [],
            winningTeam: nil,
            gameSettings: RallyEnvironment(
                isWinByTwo: true,
                scoreLimit: RallyScoreLimit.eleven,
                serveInterval: .two,
                teams: [
                    RallyTeam.teamA,
                    RallyTeam.teamB
                ]
            ))
        
        state = rallyGameReducer(state, .statusChanged(.active))
        
        XCTAssertEqual(state.gameState, RallyGameStatus.active)
        XCTAssertEqual(state.gameLog[0], .init(.gameStatusChanged(.active)))
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        
        XCTAssertEqual(state.score[RallyTeam.teamA.id], 1)
        XCTAssertEqual(state.gameLog[1], .init(.score(RallyTeam.teamA, 1)))
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        
        XCTAssertEqual(state.score[RallyTeam.teamA.id], 2)
        XCTAssertEqual(state.gameLog[2], .init(.score(RallyTeam.teamA, 2)))
        XCTAssertEqual(state.serveState.servingTeam, RallyTeam.teamB)
        XCTAssertEqual(state.gameLog[3], .init(.serviceChange(RallyTeam.teamB)))
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        
        XCTAssertEqual(state.score[RallyTeam.teamB.id], 1)
        XCTAssertEqual(state.gameLog[4], .init(.score(RallyTeam.teamB, 1)))
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        XCTAssertEqual(state.score[RallyTeam.teamA.id], 3)
        XCTAssertEqual(state.gameLog[5], .init(.score(RallyTeam.teamA, 3)))
        XCTAssertEqual(state.serveState.servingTeam, RallyTeam.teamA)
        XCTAssertEqual(state.gameLog[6], .init(.serviceChange(RallyTeam.teamA)))
        
        state = rallyGameReducer(state, .statusChanged(.paused))
        XCTAssertEqual(state.gameState, RallyGameStatus.paused)
        XCTAssertEqual(state.gameLog[7], .init(.gameStatusChanged(.paused)))
        
        state = rallyGameReducer(state, .statusChanged(.active))
        XCTAssertEqual(state.gameState, RallyGameStatus.active)
        XCTAssertEqual(state.gameLog[8], .init(.gameStatusChanged(.active)))
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        
        XCTAssertEqual(state.score[RallyTeam.teamB.id], 2)
        XCTAssertEqual(state.gameLog[9], .init(.score(RallyTeam.teamB, 2)))
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        
        XCTAssertEqual(state.score[RallyTeam.teamB.id], 3)
        XCTAssertEqual(state.gameLog[10], .init(.score(RallyTeam.teamB, 3)))
        XCTAssertEqual(state.serveState.servingTeam, RallyTeam.teamB)
        XCTAssertEqual(state.gameLog[11], .init(.serviceChange(RallyTeam.teamB)))
    }
    
    func testStateEncoding() {
        Current.date = { .distantFuture }
        Current.uuid = { UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")! }

        var state = RallyState(
            serveState: RallyServeState(servingTeam: RallyTeam.teamA),
            score: [
                RallyTeam.teamA.id: 0,
                RallyTeam.teamB.id: 0
            ],
            gameState: .ready,
            gameLog: [],
            winningTeam: nil,
            gameSettings: RallyEnvironment(
                isWinByTwo: true,
                scoreLimit: RallyScoreLimit.eleven,
                serveInterval: .two,
                teams: [
                    RallyTeam.teamA,
                    RallyTeam.teamB
                ]
            ))
        
        state = rallyGameReducer(state, .statusChanged(.active))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        state = rallyGameReducer(state, .statusChanged(.paused))
        state = rallyGameReducer(state, .statusChanged(.active))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        
        state.score = [
            RallyTeam.teamA.id: 9,
            RallyTeam.teamB.id: 6
        ]
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))

        let encoded = try! JSONEncoder().encode(state)
        let decoded = try? JSONDecoder().decode(RallyState.self, from: encoded)
        
        
        
        XCTAssertEqual(state, decoded)
    }
}
