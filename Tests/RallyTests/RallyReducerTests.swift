import XCTest
@testable import Rally

extension RallyGameStatus: CaseIterable {
    public static var allCases: [RallyGameStatus] = [
        .ready,
        .active,
        .gamePoint("TeamId"),
        .complete,
        .paused,
        .cancelled
    ]
}

final class RallyReducerTests: XCTestCase {
    var state = RallyState(
        serveState: .init(servingTeam: RallyTeam.teamA),
        score: [
            RallyTeam.teamA.id: 0,
            RallyTeam.teamB.id: 0
        ],
        gameState: .active,
        gameSettings: .mocked
    )
    
    var environment = RallyEnvironment(
        isWinByTwo: true,
        scoreLimit: RallyScoreLimit.eleven,
        serveInterval: .two,
        teams: [
            RallyTeam.teamA,
            RallyTeam.teamB
        ]
    )
    
    static var allTests = [
        ("testReducer_Score", testReducer_Score),
    ]
    
    func testReducer_Score() {
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        XCTAssertEqual(state.score, [RallyTeam.teamA.id: 1, RallyTeam.teamB.id: 0])
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        XCTAssertEqual(state.score, [RallyTeam.teamA.id: 2, RallyTeam.teamB.id: 0])
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        XCTAssertEqual(state.score, [RallyTeam.teamA.id: 2, RallyTeam.teamB.id: 1])
    }
    
    func testReducer_GameStatus() {
        RallyGameStatus.allCases.forEach {
            state = rallyGameReducer(state, .statusChanged($0))
            XCTAssertEqual(state.gameState, $0)
        }
    }
    
    func testRallyGameStatus_HumanReadable() {
        let score = GameEvent.score(RallyTeam.teamA, 1)
        XCTAssertEqual("teamA scored.", score.humanReadable)
        
        let serviceChange = GameEvent.serviceChange(RallyTeam.teamB)
        XCTAssertEqual("teamB now serving.", serviceChange.humanReadable)
        
        let gameWon = GameEvent.gameWon(RallyTeam.teamA)
        XCTAssertEqual("teamA has won.", gameWon.humanReadable)
        
        let gamePoint = GameEvent.gamePoint(RallyTeam.teamA)
        XCTAssertEqual("teamA has game point.", gamePoint.humanReadable)
        
        RallyGameStatus.allCases.forEach { status in
            let event = GameEvent.gameStatusChanged(status)
            XCTAssertEqual("Game status changed to: \(status.name)", event.humanReadable)
        }
    }
    
    func testReducer_GameComplete() {
        state.score = [
            RallyTeam.teamA.id: 10,
            RallyTeam.teamB.id: 9
        ]
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        XCTAssertEqual(state.score, [RallyTeam.teamA.id: 11, RallyTeam.teamB.id: 9])
        XCTAssertEqual(state.gameState, .complete)
        XCTAssertEqual(state.winningTeam, RallyTeam.teamA)
        XCTAssertEqual(state.serveState.servingTeam, RallyTeam.teamB)
    }
    
    func testReducer_GameComplete_teamB() {
        state.score = [
            RallyTeam.teamA.id: 9,
            RallyTeam.teamB.id: 10
        ]
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        XCTAssertEqual(state.score, [RallyTeam.teamA.id: 9, RallyTeam.teamB.id: 11])
        XCTAssertEqual(state.gameState, .complete)
        XCTAssertEqual(state.winningTeam, RallyTeam.teamB)
        XCTAssertEqual(state.serveState.servingTeam, RallyTeam.teamA)
    }
    
    func testReducer_ServiceChange() {
        state.serveState.servingTeam = RallyTeam.teamB
        state.score = [
            RallyTeam.teamA.id: 0,
            RallyTeam.teamB.id: 0
        ]
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        XCTAssertEqual(state.serveState.servingTeam, RallyTeam.teamB)
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        XCTAssertEqual(state.serveState.servingTeam, RallyTeam.teamA)
        XCTAssertEqual(state.score, [
                        RallyTeam.teamA.id: 0,
                        RallyTeam.teamB.id: 2
        ])
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        XCTAssertEqual(state.serveState.servingTeam, RallyTeam.teamA)
        XCTAssertEqual(state.score, [
                        RallyTeam.teamA.id: 1,
                        RallyTeam.teamB.id: 2
        ])
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        XCTAssertEqual(state.serveState.servingTeam, RallyTeam.teamB)
        XCTAssertEqual(state.score, [
                        RallyTeam.teamA.id: 1,
                        RallyTeam.teamB.id: 3
        ])
        
        XCTAssertNil(state.winningTeam)
    }
    
    func testReducer_GameLog() {
        Current.date = { .distantFuture }
        Current.uuid = { UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")! }
        
        state.score = [
            RallyTeam.teamA.id: 0,
            RallyTeam.teamB.id: 0
        ]
        
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        state = rallyGameReducer(state, .statusChanged(.paused))
        state = rallyGameReducer(state, .statusChanged(.active))
        
        state.score = [
            RallyTeam.teamA.id: 9,
            RallyTeam.teamB.id: 8
        ]

        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamB.id))
        state = rallyGameReducer(state, .teamScored(RallyTeam.teamA.id))

        let expectedLogs: [RallyGameEvent] = [
            .init(.score(RallyTeam.teamB, 1)),
            .init(.score(RallyTeam.teamA, 1)),
            .init(.serviceChange(RallyTeam.teamB)),
            .init(.score(RallyTeam.teamA, 2)),
            .init(.gameStatusChanged(.paused)),
            .init(.gameStatusChanged(.active)),
            .init(.score(RallyTeam.teamA, 10)),
            .init(.gamePoint(RallyTeam.teamA)),
            .init(.score(RallyTeam.teamB, 9)),
            .init(.score(RallyTeam.teamA, 11)),
            .init(.gameWon(RallyTeam.teamA)),
            .init(.gameStatusChanged(.complete))
        ]
        
        XCTAssertEqual(state.gameLog, expectedLogs)
    }
}
