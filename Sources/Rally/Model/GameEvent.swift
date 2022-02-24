import Foundation

/// Game Event
///
/// Object that represents an event in the game.
/// This could be a score, or a change in the game state.
public struct RallyGameEvent: Equatable, Identifiable, Codable {
    /// Date that the event occured
    public let date: Date
    public let event: GameEvent
    public let id: UUID
    
    /// Readable timeline entry.
    public var timeLineEntry: String {
        return "\(date.mediumTimeFormat.lowercased()) - \(event.humanReadable)"
    }
    
    public init(_ event: GameEvent) {
        self.date = Current.date()
        self.id = Current.uuid()
        self.event = event
    }
}

/// Game Event
///
/// Events that a player may want to see after a match is complete.
/// Events can be used to create a timeline of the match.
public enum GameEvent: Equatable {
    /// Team has scored.
    ///
    /// Associated Values:
    /// - RallyTeam: the team that scored
    /// - Int: The teams current score
    case score(RallyTeam, Int)
    
    /// Service has changed.
    ///
    /// Associated Values:
    /// - RallyTeam: the team that is now serving
    case serviceChange(RallyTeam)
    
    /// Game status has changed
    ///
    /// Associated Values:
    /// - RallyGameStatus: New game status
    case gameStatusChanged(RallyGameStatus)
    
    /// A team has won and the game is complete.
    ///
    /// Associated Values:
    /// - RallyTeam: the team that won the game
    case gameWon(RallyTeam)
    
    /// A Team has game game point
    ///
    /// Associated Values:
    /// - RallyTeam: the team that has game point.
    case gamePoint(RallyTeam)
    
    /// A readable description of the event.
    public var humanReadable: String {
        switch self {
        case .score(let team, _):
            return "\(team.teamName) scored."
        case .gameWon(let team):
            return "\(team.teamName) has won."
        case .gameStatusChanged(let status):
            return "Game status changed to: \(status.name)"
        case .serviceChange(let team):
            return "\(team.teamName) now serving."
        case .gamePoint(let team):
            return "\(team.teamName) has game point."
        }
    }
}

extension Date {
    /// Returns time in the medium time style.
    var mediumTimeFormat: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: self)
    }
}

extension GameEvent: Codable {
    enum CodingKeys: CodingKey {
        case score, serviceChange, gameStatusChanged, gameWon, gamePoint
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .score(team, score):
            try container.encodeValues(team, score, for: .score)
            
        case let .serviceChange(team):
            try container.encode(team, forKey: .serviceChange)
            
        case let .gameStatusChanged(status):
            try container.encode(status, forKey: .gameStatusChanged)
            
        case let .gameWon(team):
            try container.encode(team, forKey: .gameWon)
            
        case let .gamePoint(team):
            try container.encode(team, forKey: .gamePoint)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {

        case .score:
            let (team, score): (RallyTeam, Int) = try container.decodeValues(for: .score)
            self = .score(team, score)
            
        case .serviceChange:
            let subview = try container.decode(
                RallyTeam.self,
                forKey: .serviceChange
            )
            self = .serviceChange(subview)
            
        case .gameWon:
            let subview = try container.decode(
                RallyTeam.self,
                forKey: .gameWon
            )
            self = .gameWon(subview)
            
        case .gamePoint:
            let subview = try container.decode(
                RallyTeam.self,
                forKey: .gamePoint
            )
            self = .gamePoint(subview)
            
        case .gameStatusChanged:
            let subview = try container.decode(
                RallyGameStatus.self,
                forKey: .gameStatusChanged
            )
            self = .gameStatusChanged(subview)
            
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
}

extension KeyedEncodingContainer {
    mutating func encodeValues<V1: Encodable, V2: Encodable>(
        _ v1: V1,
        _ v2: V2,
        for key: Key) throws {

        var container = self.nestedUnkeyedContainer(forKey: key)
        try container.encode(v1)
        try container.encode(v2)
    }
}

extension KeyedDecodingContainer {
    func decodeValues<V1: Decodable, V2: Decodable>(
        for key: Key) throws -> (V1, V2) {

        var container = try self.nestedUnkeyedContainer(forKey: key)
        return (
            try container.decode(V1.self),
            try container.decode(V2.self)
        )
    }
}
