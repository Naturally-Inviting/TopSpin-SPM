import XCTest
@testable import Rally

final class RallyServeTests: XCTestCase {
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
        ("testServeState", testServeState),
    ]
    
    func testServeState_InitialState() {
        let servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamA)
    }
    
    func testServeState() {
       state.score = [
            RallyTeam.teamA.id: 1,
            RallyTeam.teamB.id: 0
        ]
        
        let servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamA)
    }
    
    func testServeState_ChangeServes() {
        state.score = [
            RallyTeam.teamA.id: 1,
            RallyTeam.teamB.id: 1
        ]
        
        let servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamB)
    }
    
    func testServeState_GamePoint() {
        state.score = [
            RallyTeam.teamA.id: 9,
            RallyTeam.teamB.id: 10
        ]
        
        let servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamA)
    }
    
    func testServeState_AboveGamePoint() {
       state.score = [
            RallyTeam.teamA.id: 13,
            RallyTeam.teamB.id: 14
        ]
        
        let servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamA)
    }
    
    func testServeState_ServingTeamGamePoint() {
        state.score = [
            RallyTeam.teamA.id: 10,
            RallyTeam.teamB.id: 9
        ]
        
        let servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamB)
    }
    
    func testServeState_ServingTeamAboveGamePoint() {
        state.score = [
            RallyTeam.teamA.id: 13,
            RallyTeam.teamB.id: 12
        ]
        
        let servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamB)
    }
    
    func testServeState_ContinueAfterGamePoint() {
        state.score = [
            RallyTeam.teamA.id: 9,
            RallyTeam.teamB.id: 9
        ]
        
        var servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamB)
        
        state.serveState.servingTeam = servingTeam
        state.score = [
            RallyTeam.teamA.id: 9,
            RallyTeam.teamB.id: 10
        ]
        
        servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamA)
        
        state.serveState.servingTeam = servingTeam
        state.score = [
            RallyTeam.teamA.id: 10,
            RallyTeam.teamB.id: 10
        ]
        
        servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamA)
        
        state.serveState.servingTeam = servingTeam
        state.score = [
            RallyTeam.teamA.id: 11,
            RallyTeam.teamB.id: 10
        ]
        
        servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamB)
        
        state.serveState.servingTeam = servingTeam
        state.score = [
            RallyTeam.teamA.id: 11,
            RallyTeam.teamB.id: 11
        ]
        
        servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamB)
    }
    
    func testServeState_Interval() {
        environment.serveInterval = .five
        
        state.score = [
            RallyTeam.teamA.id: 4,
            RallyTeam.teamB.id: 0
        ]
        
        var servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamA)
        
        state.serveState.servingTeam = servingTeam
        state.score = [
            RallyTeam.teamA.id: 4,
            RallyTeam.teamB.id: 1
        ]
        
        servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamB)
    }
    
    func testServeState_Interval_NotWinByTwo() {
        environment.serveInterval = .five
        environment.isWinByTwo = false
        
        state.score = [
            RallyTeam.teamA.id: 9,
            RallyTeam.teamB.id: 3
        ]
        
        var servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamA)
        
        state.serveState.servingTeam = servingTeam
        state.score = [
            RallyTeam.teamA.id: 10,
            RallyTeam.teamB.id: 4
        ]
        
        servingTeam = determineServingTeam(state, environment)
        XCTAssertTrue(servingTeam == RallyTeam.teamB)
    }
}

