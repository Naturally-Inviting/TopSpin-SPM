import Foundation

public typealias TeamId = String
/// Represents a team in a game.
///
/// For now, a team is represented by one player.
public struct RallyTeam: Equatable, Codable {
    /// Unique identifier of a team
    public let id: TeamId
    /// Team or player name
    public let teamName: String
    
    public init(id: TeamId, teamName: String) {
        self.id = id
        self.teamName = teamName
    }
}
