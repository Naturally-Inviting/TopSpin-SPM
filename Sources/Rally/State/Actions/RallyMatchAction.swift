import Foundation

public enum RallyMatchStatus: String, Equatable, Codable {
    case active
    case complete
    case cancelled
}

/// Actions that can be dispatched to a Rally match reducer
public enum RallyMatchAction: Equatable {
    case matchStatusChanged(RallyMatchStatus)
    /// Actions specific to a game.
    case gameAction(RallyAction)
}
