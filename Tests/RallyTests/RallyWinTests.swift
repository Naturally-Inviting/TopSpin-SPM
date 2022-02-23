import XCTest
@testable import Rally

final class RallyWinTests: XCTestCase {
   
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
        ("testWinState", testWinState),
    ]
    
    func testWinState() {
        let score = [
            RallyTeam.teamA.id: 0,
            RallyTeam.teamB.id: 0
        ]
        
        let winningTeam = didTeamWin(score, environment)
        XCTAssertNil(winningTeam)
    }
    
    func testWinState_NoScores() {
        let winningTeam = didTeamWin([:], environment)
        XCTAssertNil(winningTeam)
    }
    
    func testWinState_teamA() {
        let score = [
            RallyTeam.teamA.id: 11,
            RallyTeam.teamB.id: 9
        ]
        
        let winningTeam = didTeamWin(score, environment)
        XCTAssertEqual(winningTeam, RallyTeam.teamA)
    }
    
    func testWinState_teamB() {
        let score = [
            RallyTeam.teamA.id: 9,
            RallyTeam.teamB.id: 11
        ]
        
        let winningTeam = didTeamWin(score, environment)
        XCTAssertEqual(winningTeam, RallyTeam.teamB)
    }
    
    func testWinState_GamePoint() {
        let score = [
            RallyTeam.teamA.id: 10,
            RallyTeam.teamB.id: 9
        ]
        
        let winningTeam = didTeamWin(score, environment)
        XCTAssertNil(winningTeam)
    }
    
    func testWinState_PastGamePoint() {
        var score = [
            RallyTeam.teamA.id: 13,
            RallyTeam.teamB.id: 11
        ]
        
        var winningTeam = didTeamWin(score, environment)
        XCTAssertEqual(winningTeam, RallyTeam.teamA)
        
        score = [
            RallyTeam.teamA.id: 11,
            RallyTeam.teamB.id: 13
        ]
                
        winningTeam = didTeamWin(score, environment)
        XCTAssertEqual(winningTeam, RallyTeam.teamB)
    }
    
    func testWinState_NoWinByTwo() {
        var score = [
            RallyTeam.teamA.id: 11,
            RallyTeam.teamB.id: 10
        ]
        
        environment.isWinByTwo = false
        
        var winningTeam = didTeamWin(score, environment)
        XCTAssertEqual(winningTeam, RallyTeam.teamA)
        
        score = [
            RallyTeam.teamA.id: 10,
            RallyTeam.teamB.id: 11
        ]
                
        winningTeam = didTeamWin(score, environment)
        XCTAssertEqual(winningTeam, RallyTeam.teamB)
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
    
    func testGameStatus_TimelineEntry() {
        Current.date = { .distantFuture }
        
        let score = GameEvent.score(RallyTeam.teamA, 1)
        let event = RallyGameEvent(score)
        XCTAssertEqual("5:00:00 pm - teamA scored.", event.timeLineEntry)
    }
}
