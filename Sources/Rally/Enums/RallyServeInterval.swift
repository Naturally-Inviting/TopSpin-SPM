import Foundation

/// Serve interval for a `RallyGame`.
///
/// In game to 11 this is typically 2,
/// and 5 for a game to 21.
/// One would mean the game will switch serves between every rally.
public enum RallyServeInterval: Int, Equatable, Codable {
    case one = 1
    case two = 2
    case five = 5
    case seven = 7
}
