import XCTest
@testable import Rally

final class MatchReducerTests: XCTestCase {
   
    var state = RallyMatchState(
        matches: [
            .init(
                serveState: .init(
                    servingTeam: RallyTeam.teamA
                ),
                score: [RallyTeam.teamA.id: 0, RallyTeam.teamB.id: 0],
                gameState: .ready,
                gameSettings: .mocked
            ),
            .init(
                serveState: .init(
                    servingTeam: RallyTeam.teamB
                ),
                score: [RallyTeam.teamA.id: 0, RallyTeam.teamB.id: 0],
                gameState: .ready,
                gameSettings: .mocked)
            ,
            .init(
                serveState: .init(
                    servingTeam: RallyTeam.teamA
                ),
                score: [RallyTeam.teamA.id: 0, RallyTeam.teamB.id: 0],
                gameState: .ready,
                gameSettings: .mocked
            )
        ],
        matchSettings: .mocked
    )
    
    static var allTests = [
        ("testMatchReducer", testMatchReducer),
    ]
    
    func testMatchReducer() {
        state = rallyMatchReducer(state, .gameAction(.statusChanged(.active)))
        state = rallyMatchReducer(state, .gameAction(.teamScored(RallyTeam.teamA.id)))
        
        var currentMatch = state.currentMatch
        
        XCTAssertEqual(currentMatch.gameState, .active)
        XCTAssertEqual(currentMatch.score[RallyTeam.teamA.id], 1)
        
        state = rallyMatchReducer(state, .gameAction(.teamScored(RallyTeam.teamB.id)))
        currentMatch = state.currentMatch

        XCTAssertEqual(currentMatch.score[RallyTeam.teamB.id], 1)
    }
    
    func testReducer_MatchWin() {
        state.matches[0].score = [
            RallyTeam.teamA.id: 10,
            RallyTeam.teamB.id: 8
        ]
        
        state = rallyMatchReducer(state, .gameAction(.teamScored(RallyTeam.teamA.id)))
        XCTAssertEqual(state.matches[0].gameState, .complete)
        XCTAssertEqual(state.matches[0].winningTeam, RallyTeam.teamA)
        XCTAssertEqual(state.currentMatchIndex, 1)
        
        state.matches[1].score = [
            RallyTeam.teamA.id: 10,
            RallyTeam.teamB.id: 8
        ]
        state.matches[1].gameState = .active
        
        state = rallyMatchReducer(state, .gameAction(.teamScored(RallyTeam.teamA.id)))
        XCTAssertEqual(state.matches[1].gameState, .complete)
        XCTAssertEqual(state.matches[1].winningTeam, RallyTeam.teamA)
        XCTAssertEqual(state.currentMatchIndex, 2)
        XCTAssertEqual(state.winningTeam, RallyTeam.teamA)
        XCTAssertEqual(state.matchStatus, .complete)
    }
    
    func testBaseState() {
        let wonMatches = state.matches.contains(where: { $0.winningTeam != nil })

        XCTAssertEqual(state.currentMatchIndex, 0)
        XCTAssertFalse(wonMatches)
        XCTAssertFalse(state.isMatchPoint)
        XCTAssertEqual(state.matchStatus, .active)
        XCTAssertNil(state.winningTeam)
    }
    
    func testReducer_StateChange() {
        state = rallyMatchReducer(state, .matchStatusChanged(.cancelled))
        XCTAssertEqual(state.matchStatus, .cancelled)
    }
}
