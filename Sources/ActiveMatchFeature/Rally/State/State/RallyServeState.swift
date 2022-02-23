import Foundation

public struct RallyServeState: Equatable, Codable {
    public var servingTeam: RallyTeam

    public init(servingTeam: RallyTeam) {
        self.servingTeam = servingTeam
    }
}
