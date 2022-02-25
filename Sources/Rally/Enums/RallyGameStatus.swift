import Foundation

/// Rally Game Status
///
/// Status of a game.
public enum RallyGameStatus: Equatable, Codable {
    /// Game is ready to start
    case ready
    /// Game is actively being played
    case active
    /// A Rally Team has game point
    case gamePoint(TeamId)
    /// Game has completed with a winner
    case complete
    /// Game is paused
    case paused
    /// Game has been cancelled
    case cancelled
    
    /// Human readable status
    public var name: String {
        switch self {
        case .ready: return "Ready"
        case .active: return "Active"
        case .gamePoint(let teamId): return "Game Point for \(teamId)"
        case .complete: return "Complete"
        case .paused: return "Paused"
        case .cancelled: return "Cancelled"
        }
    }
}
