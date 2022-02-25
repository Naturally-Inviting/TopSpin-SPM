import Foundation

public func rallyGameReducer(_ state: RallyState, _ action: RallyAction) -> RallyState {
    var state = state
    switch action {
    case .statusChanged(let status):
        state.gameState = status
        state.gameLog.append(.init(.gameStatusChanged(status)))
        
    case .teamScored(let id):
        if let score = state.score[id] {
            state.score[id] = score + 1
            
            if let team = state.gameSettings.teams.map({$0}).first(where: { $0.id == id }) {
                state.gameLog.append(.init(.score(team, score + 1)))
            }
        }
        
        // Determine If there is a win.
        if let winningTeam = didTeamWin(state.score, state.gameSettings) {
            state.winningTeam = winningTeam
            state.isGamePoint = false
            state.gameState = .complete
            state.gameLog.append(.init(.gameWon(winningTeam)))
            state.gameLog.append(.init(.gameStatusChanged(.complete)))
        }
        
        // Determine Serve state
        let servingTeam = determineServingTeam(state, state.gameSettings)
        
        if servingTeam != state.serveState.servingTeam {
            state.serveState.servingTeam = servingTeam
            state.gameLog.append(.init(.serviceChange(servingTeam)))
        }
        
        // Determine if game point only when there is no winner
        if state.winningTeam == nil, let team = determineTeamHasGamePoint(state, state.gameSettings) {
            // Only change state when it is not game point.
            // It is impossible to get game point after one rally.
            if !state.isGamePoint {
                state.isGamePoint = true
                state.gameState = .gamePoint(team.id)
                state.gameLog.append(.init(.gamePoint(team)))
            }
        } else {
            state.isGamePoint = false
            
            // When previously game point, reset to active.
            if case .gamePoint = state.gameState {
                state.gameState = .active
            }
        }
    }
    
    return state
}
