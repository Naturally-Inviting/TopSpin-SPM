import Foundation

public enum RallyMatchStatus: Equatable, Codable {
    case active
    case matchPoint(TeamId)
    case complete
    case cancelled
}

/// Actions that can be dispatched to a Rally match reducer
public enum RallyMatchAction: Equatable {
    case matchStatusChanged(RallyMatchStatus)
    /// Actions specific to a game.
    case gameAction(RallyAction)
}
