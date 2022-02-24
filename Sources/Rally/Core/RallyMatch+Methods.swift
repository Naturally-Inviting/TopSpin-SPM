import Foundation

/// Returns a RallyTeam if there is a team that wins the match.
/// This means the team has won the necessary amount of games.
/// ie. 2 out of 3, or 4 for 7.
/// - Parameters:
///   - state: Current RallyMatchState
///   - environment: RallyMatchEnvironment constants
/// - Returns: Returns a team if they win the match. If no winner, return nil.
internal func matchWinningTeam(_ state: RallyMatchState) -> RallyTeam? {
    let teams = state.matchSettings.matchSettings.teams.map({ $0 })
    
    return teams.first { team in
        let wins = state.matches.filter({ $0.winningTeam == team }).count
        return wins == state.matchSettings.neededToWin
    }
}

/// Boolean indicating whether or not a match has match point.
/// Match point is when a team needs one more point to win the match.
/// The method checks any team needs one more match to win
/// and if they have game point in that current game.
/// - Parameters:
///   - state: Current RallyMatchState
///   - environment: Current RallyMatchEnvironment
/// - Returns: True if a team has match point.
internal func isMatchPoint(_ state: RallyMatchState) -> Bool {
    let teams = state.matchSettings.matchSettings.teams.map({ $0 })
    let currentMatch = state.matches[state.currentMatchIndex]
    
    /// Data structure to include key match details for team wins and the score for the current match.
    struct MatchDetail {
        let teamId: TeamId
        let wins: Int
        let currentMatchScore: Int
    }
    
    let winMap: [MatchDetail] = teams.map { team in
        let wins = state.matches.filter({ $0.winningTeam == team }).count
        let currentMatchScore = currentMatch.score[team.id] ?? 0
        return MatchDetail(teamId: team.id, wins: wins, currentMatchScore: currentMatchScore)
    }
    
    return winMap.contains { teamWin in
        guard let opposingTeamId = state.matchSettings.matchSettings.teams.first(where: { $0.id != teamWin.teamId })?.id else { return false }
        let opposingCurrentMatchScore = currentMatch.score[opposingTeamId] ?? 0
        
        if teamWin.wins == state.matchSettings.neededToWin - 1 {
            return hasGamePoint(for: teamWin.currentMatchScore, against: opposingCurrentMatchScore, state.matchSettings.matchSettings)
        }
        
        return false
    }
}
