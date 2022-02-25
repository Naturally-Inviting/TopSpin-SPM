import Foundation

public enum RallyTeamStatus: Int, CaseIterable, Equatable, Codable {
    case active = 1
    case gamePoint
    case matchPoint
    case winner
    case loser
    
    /// Human readable status
    public var name: String {
        switch self {
        case .active: return "Active"
        case .gamePoint: return "Game Point"
        case .matchPoint: return "Match Point"
        case .winner: return "Winner"
        case .loser: return "Loser"
        }
    }
}
