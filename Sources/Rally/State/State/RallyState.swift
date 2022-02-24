import Foundation

public struct RallyState: Equatable, Codable {
    public var serveState: RallyServeState
    public var score: [TeamId: Int]
    public var gameState: RallyGameStatus
    public var gameLog: [RallyGameEvent] = [RallyGameEvent]()
    public var isGamePoint: Bool = false
    public var winningTeam: RallyTeam? = nil
    
    public var gameSettings: RallyEnvironment
    
    public init(serveState: RallyServeState,
                score: [TeamId : Int],
                gameState: RallyGameStatus,
                gameLog: [RallyGameEvent] = [RallyGameEvent](),
                isGamePoint: Bool = false,
                winningTeam: RallyTeam? = nil,
                gameSettings: RallyEnvironment
    ) {
        self.serveState = serveState
        self.score = score
        self.gameState = gameState
        self.gameLog = gameLog
        self.isGamePoint = isGamePoint
        self.winningTeam = winningTeam
        self.gameSettings = gameSettings
    }
}
