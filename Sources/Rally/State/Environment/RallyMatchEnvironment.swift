import Foundation

public struct RallyMatchEnvironment: Equatable, Codable {
    public var matchCount: Int = MatchLimit.three
    public var matchSettings: RallyEnvironment
    
    public var neededToWin: Int {
        return (matchCount / 2) + 1
    }
    
    public init(matchCount: Int = MatchLimit.three, matchSettings: RallyEnvironment) {
        self.matchCount = matchCount
        self.matchSettings = matchSettings
    }
}
