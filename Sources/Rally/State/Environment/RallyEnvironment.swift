import Foundation

/// Rally Environment is the 'Environment' dependencies for a game.
/// These include win by two, score limit, how often service should change.
/// These values should not change throughout the game.
/// Scores and current server will be reflected in RallyState.
public struct RallyEnvironment: Equatable, Codable {
    public var isWinByTwo: Bool = true
    public var scoreLimit: Int = RallyScoreLimit.eleven
    public var serveInterval: RallyServeInterval = .two
    public var teams: [RallyTeam] = []
    
    public init(isWinByTwo: Bool = true, scoreLimit: Int = RallyScoreLimit.eleven, serveInterval: RallyServeInterval = .two, teams: [RallyTeam] = []) {
        self.isWinByTwo = isWinByTwo
        self.scoreLimit = scoreLimit
        self.serveInterval = serveInterval
        self.teams = teams
    }
}
