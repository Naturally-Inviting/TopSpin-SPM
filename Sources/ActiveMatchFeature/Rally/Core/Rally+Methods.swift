import Foundation

/// Checks the game state and determines if there is a winning team.
/// - Parameters:
///   - scores: Dictionary of TeamId as a key and the score as an Int as the value
///   - environment: Constants for the life span of the 'game'.
/// - Returns: If there is a winning team, return that team but return nil if there are no winning teams.
internal func didTeamWin(_ scores: [TeamId: Int], _ environment: RallyEnvironment) -> RallyTeam? {
    let scoreLimit = environment.scoreLimit
    let teams = environment.teams.map { $0 }
    
    guard scores.keys.count == 2 else {
        return nil
    }
    
    let teamA = teams[0]
    let teamB = teams[1]
    
    let teamAScore = scores[teamA.id] ?? 0
    let teamBScore = scores[teamB.id] ?? 0
    
    if environment.isWinByTwo {
        if teamAScore == scoreLimit && (teamBScore <= (scoreLimit - 2)) {
            return teamA
        } else if teamAScore > scoreLimit && teamBScore == (teamAScore - 2) { // if teamScore is above the limit, if the opposing team score is == 2 - teamScore then team score has won.
            return teamA
        }
        
        if teamBScore == scoreLimit && (teamAScore <= (scoreLimit - 2)) {
            return teamB
        } else if teamBScore > scoreLimit && teamAScore == (teamBScore - 2) { // if teamScore is above the limit, if the opposing team score is == 2 - teamScore then team score has won.
            return teamB
        }
    } else if teamAScore == scoreLimit {
        return teamA
    } else if teamBScore == scoreLimit {
        return teamB
    }
    
    return nil
}

/// A method that checks the current game if any team has game point.
///
/// - Parameters:
///   - state: Current state of the game
///   - environment: Constants for the life span of the 'game'.
/// - Returns: An optional `RallyTeam`. Returns a team that has game point else nil.
internal func determineTeamHasGamePoint(_ state: RallyState, _ environment: RallyEnvironment) -> RallyTeam? {
    let servingTeam = state.serveState.servingTeam
    let teams = environment.teams
    
    guard teams.count == 2 else { return nil }
    
    guard let opponent = environment.teams.first(where: { $0.id != servingTeam.id }) else { return nil }
        
    let servingScore = state.score[servingTeam.id] ?? 0
    let opponentScore = state.score[opponent.id] ?? 0
    
    if hasGamePoint(for: servingScore, against: opponentScore, environment) {
        return servingTeam
    } else if hasGamePoint(for: opponentScore, against: servingScore, environment) {
        return opponent
    }
    
    return nil
}

internal func determineServingTeam(_ state: RallyState, _ environment: RallyEnvironment) -> RallyTeam {
    let servingTeam = state.serveState.servingTeam
    let teams = environment.teams
    
    guard teams.count == 2 else {
        fatalError("Rally must initialize with two teams")
    }
    
    guard let opponent = environment.teams.first(where: { $0.id != servingTeam.id }) else {
        fatalError("Could not determine other team")
    }
    
    // Idea, checking if service should not be the current server.
    
    // If the Opponent has game point, remain server.
    let servingScore = state.score[servingTeam.id] ?? 0
    let opponentScore = state.score[opponent.id] ?? 0
    
    if servingScore == environment.scoreLimit - 1 && opponentScore == environment.scoreLimit - 1 {
        return servingTeam
    }
    
    let servingTeamHasGamePoint = hasGamePoint(for: servingScore, against: opponentScore, environment)
    let opponentHasGamePoint = hasGamePoint(for: opponentScore, against: servingScore, environment)
    
    if servingTeamHasGamePoint {
        return opponent
    }
    
    if opponentHasGamePoint {
        return servingTeam
    }
    
    // If scores are above or equal to the limit and neither have game point, return the current serving team.
    if servingScore >= environment.scoreLimit && opponentScore >= environment.scoreLimit && !servingTeamHasGamePoint && !opponentHasGamePoint {
        return servingTeam
    }
    
    // If the scores added up are equally divisible by the serve interval, swap.
    // Score must be greater than 0
    let scoreTotal = state.score.values.reduce(0, +)
    if scoreTotal > 0 && scoreTotal % environment.serveInterval.rawValue == 0 {
        return opponent
    }
    
    return servingTeam
}

internal func hasGamePoint(for score: Int, against opponent: Int, _ environment: RallyEnvironment) -> Bool {
    let teamHasSinglePointToScore = score >= environment.scoreLimit - 1
    let opponentHasSinglePointToScore = opponent >= environment.scoreLimit - 1

    if teamHasSinglePointToScore && !opponentHasSinglePointToScore {
        return true
    } else if score >= environment.scoreLimit && opponent >= environment.scoreLimit - 1 && environment.isWinByTwo {
        // Only way a team can have higher that limit is win by two.
        return teamHasSinglePointToScore && opponent <= (score - 1)
    } else {
        return false
    }
}
