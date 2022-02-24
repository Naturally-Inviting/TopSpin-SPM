import Foundation

/// Rally Game Status
///
/// Status of a game.
public enum RallyGameStatus: Int, CaseIterable, Equatable, Codable {
    /// Game is ready to start
    case ready = 1
    /// Game is actively being played
    case active
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
        case .complete: return "Complete"
        case .paused: return "Paused"
        case .cancelled: return "Cancelled"
        }
    }
}
