import Foundation


/// Rally Match Reducer
///
/// - Parameters:
///   - state: current state
///   - action: action dispatched that initiates a state change
///   - environment: Constants throughout the match life cycle that will not change
/// - Returns: A new instance of `RallyMatchState`
public func rallyMatchReducer(_ state: RallyMatchState, _ action: RallyMatchAction) -> RallyMatchState {
    var state = state
    
    switch action {
    case .matchStatusChanged(let status):
        state.matchStatus = status
        
    case .gameAction(let gameAction):
        state.matches[state.currentMatchIndex] = rallyGameReducer(state.matches[state.currentMatchIndex], gameAction)
        
        // Ensure the current match index does not go out of bounds
        if state.matches[state.currentMatchIndex].winningTeam != nil && (state.currentMatchIndex + 1) != state.matches.count {
            state.currentMatchIndex += 1
        }
        
        // Check for match win
        if let winningTeam = matchWinningTeam(state) {
            state.winningTeam = winningTeam
            state.matchStatus = .complete
            return state
        }
        
        if let teamWithMatchPoint = isMatchPoint(state) {
            state.isMatchPoint = true
            state.matchStatus = .matchPoint(teamWithMatchPoint.id)
        } else {
            state.isMatchPoint = false
            state.matchStatus = .active
        }
    }
    
    return state
}
