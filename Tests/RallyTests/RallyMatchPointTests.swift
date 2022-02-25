import XCTest
@testable import Rally

final class RallyMatchTests: XCTestCase {
    
    var state = RallyMatchState(
        matches: [
            .init(serveState: .init(servingTeam: RallyTeam.teamA), score: [RallyTeam.teamA.id: 0, RallyTeam.teamB.id: 0], gameState: .ready, gameSettings: .mocked),
            .init(serveState: .init(servingTeam: RallyTeam.teamB), score: [RallyTeam.teamA.id: 0, RallyTeam.teamB.id: 0], gameState: .ready, gameSettings: .mocked),
            .init(serveState: .init(servingTeam: RallyTeam.teamA), score: [RallyTeam.teamA.id: 0, RallyTeam.teamB.id: 0], gameState: .ready, gameSettings: .mocked)
        ],
        matchSettings: .mocked
    )
    
    func testIsMatchPoint() {
        // Test base state
        let teamWithMatchPoint = isMatchPoint(state)
        XCTAssertNil(teamWithMatchPoint)

        var gameCopy = state.matches[0]
                
        gameCopy.score = [RallyTeam.teamA.id : 11, RallyTeam.teamB.id: 5]
        gameCopy.winningTeam = RallyTeam.teamA
        
        state.matches[0] = gameCopy
        
        gameCopy = state.matches[1]
        gameCopy.score = [RallyTeam.teamA.id : 10, RallyTeam.teamB.id: 5]
        
        state.matches[1] = gameCopy
        state.currentMatchIndex = 1
        
        // Test Team A should have match point
        let teamAMatchPoint = isMatchPoint(state)
        XCTAssertNotNil(teamAMatchPoint)
        
        gameCopy = state.matches[1]
        gameCopy.score = [RallyTeam.teamA.id : 9, RallyTeam.teamB.id: 5]
        state.matches[1] = gameCopy

        // Test Team A does not have match point.
        let teamANoMatchPoint = isMatchPoint(state)
        XCTAssertNil(teamANoMatchPoint)
    }
    
    func testIsMatchWin() {
        var gameCopy = state.matches[0]
                
        gameCopy.winningTeam = RallyTeam.teamA
        
        state.matches[0] = gameCopy
        
        gameCopy = state.matches[1]
        gameCopy.winningTeam = RallyTeam.teamA
        state.matches[1] = gameCopy
        
        var winningTeam = matchWinningTeam(state)
        XCTAssertEqual(winningTeam, RallyTeam.teamA)
        
        state.matches[1].winningTeam = nil
        var nilWinningTeam = matchWinningTeam(state)
        XCTAssertNil(nilWinningTeam)
        
        gameCopy = state.matches[1]
        gameCopy.winningTeam = RallyTeam.teamB
        state.matches[1] = gameCopy
        
        nilWinningTeam = matchWinningTeam(state)
        XCTAssertNil(nilWinningTeam)
        
        gameCopy = state.matches[2]
        gameCopy.winningTeam = RallyTeam.teamA
        state.matches[2] = gameCopy
        
        winningTeam = matchWinningTeam(state)
        XCTAssertEqual(winningTeam, RallyTeam.teamA)
    }
    
    func testNeededToWin() {
        XCTAssertEqual(state.matchSettings.neededToWin, 2)
        
        state.matchSettings.matchCount = 5
        XCTAssertEqual(state.matchSettings.neededToWin, 3)
        
        state.matchSettings.matchCount = 7
        XCTAssertEqual(state.matchSettings.neededToWin, 4)
        
        state.matchSettings.matchCount = 9
        XCTAssertEqual(state.matchSettings.neededToWin, 5)
    }
}
