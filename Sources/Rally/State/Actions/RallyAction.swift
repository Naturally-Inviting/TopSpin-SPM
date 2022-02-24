import Foundation

/// Actions that can be dispatched to the game reducer
public enum RallyAction: Equatable {
    case statusChanged(RallyGameStatus)
    case teamScored(TeamId)
}
