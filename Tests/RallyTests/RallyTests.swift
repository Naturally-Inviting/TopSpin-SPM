import XCTest
@testable import Rally

final class RallyTests: XCTestCase {
    var environment = RallyEnvironment()
    
    static var allTests = [
        ("testGamePoint", testGamePoint),
    ]
    
    func testGamePoint() {
        let playerScore = 10
        let oppScore = 9
        
        environment.scoreLimit = RallyScoreLimit.eleven
        
        let playerHasGamePoint = hasGamePoint(for: playerScore, against: oppScore, environment)
        
        XCTAssertTrue(playerHasGamePoint)
    }
    
    func testNotGamePoint() {
        let playerScore = 9
        let oppScore = 9
        
        environment.scoreLimit = RallyScoreLimit.eleven
        
        let playerHasGamePoint = hasGamePoint(for: playerScore, against: oppScore, environment)
        let oppHasGamePoint = hasGamePoint(for: oppScore, against: playerScore, environment)

        XCTAssertFalse(playerHasGamePoint)
        XCTAssertFalse(oppHasGamePoint)
    }
    
    func testOppHasGamePoint() {
        let playerScore = 9
        let oppScore = 10
        
        environment.scoreLimit = RallyScoreLimit.eleven
        
        let playerHasGamePoint = hasGamePoint(for: playerScore, against: oppScore, environment)
        let oppHasGamePoint = hasGamePoint(for: oppScore, against: playerScore, environment)
        
        XCTAssertFalse(playerHasGamePoint)
        XCTAssertTrue(oppHasGamePoint)
    }
    
    func testGamePointScoreLimit() {
        let playerScore = 20
        let oppScore = 9
        
        environment.scoreLimit = RallyScoreLimit.twentyOne
        
        let playerHasGamePoint = hasGamePoint(for: playerScore, against: oppScore, environment)
        
        XCTAssertTrue(playerHasGamePoint)
    }
    
    func testGamePointAfterScoreLimit() {
        let playerScore = 13
        let oppScore = 12
        
        environment.scoreLimit = RallyScoreLimit.eleven
        
        let playerHasGamePoint = hasGamePoint(for: playerScore, against: oppScore, environment)
        let oppHasGamePoint = hasGamePoint(for: oppScore, against: playerScore, environment)
        
        XCTAssertTrue(playerHasGamePoint)
        XCTAssertFalse(oppHasGamePoint)
    }
    
    func testNoGamePointAfterScoreLimit() {
        let playerScore = 13
        let oppScore = 13
        
        environment.scoreLimit = RallyScoreLimit.eleven
        
        let playerHasGamePoint = hasGamePoint(for: playerScore, against: oppScore, environment)
        let oppHasGamePoint = hasGamePoint(for: oppScore, against: playerScore, environment)
        
        XCTAssertFalse(playerHasGamePoint)
        XCTAssertFalse(oppHasGamePoint)
    }
    
    func testDetermineTeamGamePoint() {
        let state = RallyState(
            serveState: .init(servingTeam: RallyTeam.teamA),
            score: [RallyTeam.teamA.id: 10, RallyTeam.teamB.id: 9],
            gameState: .active,
            gameSettings: .mocked
        )
        
        environment.scoreLimit = RallyScoreLimit.eleven
        environment.teams = [RallyTeam.teamA, RallyTeam.teamB]
        
        let team = determineTeamHasGamePoint(state, environment)
        
        XCTAssertTrue(team == RallyTeam.teamA)
    }
    
    func testDetermineTeamGamePoint_teamB() {
        let state = RallyState(
            serveState: .init(servingTeam: RallyTeam.teamA),
            score: [RallyTeam.teamA.id: 9, RallyTeam.teamB.id: 10],
            gameState: .active,
            gameSettings: .mocked
        )
        
        environment.scoreLimit = RallyScoreLimit.eleven
        environment.teams = [RallyTeam.teamA, RallyTeam.teamB]

        let team = determineTeamHasGamePoint(state, environment)
        
        XCTAssertTrue(team == RallyTeam.teamB)
    }
    
    func testDetermineGamePoint_NoGamePoint() {
        let state = RallyState(
            serveState: .init(servingTeam: RallyTeam.teamA),
            score: [
                RallyTeam.teamA.id: 9,
                RallyTeam.teamB.id: 9
            ],
            gameState: .active,
            gameSettings: .mocked
        )
        
        environment.scoreLimit = RallyScoreLimit.eleven
        environment.teams = [RallyTeam.teamA, RallyTeam.teamB]
        
        let team = determineTeamHasGamePoint(state, environment)
        
        XCTAssertNil(team)
    }
    
    func testDetermineGamePoint_NoStateScore() {
        let state = RallyState(
            serveState: .init(servingTeam: RallyTeam.teamA),
            score: [:],
            gameState: .active,
            gameSettings: .mocked
        )
        
        environment.scoreLimit = RallyScoreLimit.eleven
        environment.teams = [RallyTeam.teamA, RallyTeam.teamB]

        let team = determineTeamHasGamePoint(state, environment)
        
        XCTAssertNil(team)
    }
    
    func testDetermineGamePoint_NoTeams() {
        let state = RallyState(
            serveState: .init(servingTeam: RallyTeam.teamA),
            score: [:],
            gameState: .active,
            gameSettings: .mocked
        )
        
        environment.scoreLimit = RallyScoreLimit.eleven
        environment.teams = []
        
        let team = determineTeamHasGamePoint(state, environment)
        
        XCTAssertNil(team)
    }
    
    func testDetermineGamePoint_WrongId() {
        let state = RallyState(
            serveState: .init(servingTeam: RallyTeam.teamA),
            score: [:],
            gameState: .active,
            gameSettings: .mocked
        )
        
        environment.scoreLimit = RallyScoreLimit.eleven
        environment.teams = [RallyTeam.teamA, RallyTeam.teamB]

        let team = determineTeamHasGamePoint(state, environment)
        
        XCTAssertNil(team)
    }
    
    @available(iOS 13.0, *)
    func testRallyStore() {
        let state = RallyState(
            serveState: .init(servingTeam: RallyTeam.teamA),
            score: [
                RallyTeam.teamA.id: 0,
                RallyTeam.teamB.id: 0
            ],
            gameState: .active,
            gameSettings: .mocked
        )
        
        environment.scoreLimit = RallyScoreLimit.eleven
        environment.teams = [RallyTeam.teamA, RallyTeam.teamB]
        
        let store = RallyStore(state, environment)
        store.dispatch(action: .teamScored(RallyTeam.teamA.id))
        
        XCTAssertEqual(store.state.score[RallyTeam.teamA.id], 1)
    }
}
