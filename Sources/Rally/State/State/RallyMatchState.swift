import Foundation

public struct RallyMatchState: Equatable, Codable {
    public var currentMatchIndex = 0
    public var matches: [RallyState]
    public var isMatchPoint: Bool = false
    public var matchStatus: RallyMatchStatus = .active
    public var winningTeam: RallyTeam?
    public var matchSettings: RallyMatchEnvironment
    
    public init(currentMatchIndex: Int = 0,
                matches: [RallyState],
                isMatchPoint: Bool = false,
                matchStatus: RallyMatchStatus = .active,
                winningTeam: RallyTeam? = nil,
                matchSettings: RallyMatchEnvironment) {
        self.currentMatchIndex = currentMatchIndex
        self.matches = matches
        self.isMatchPoint = isMatchPoint
        self.matchStatus = matchStatus
        self.winningTeam = winningTeam
        self.matchSettings = matchSettings
    }
}

extension RallyMatchState {
    public var currentMatch: RallyState {
        return matches[currentMatchIndex]
    }
}
