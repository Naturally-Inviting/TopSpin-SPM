import SwiftUI

public enum AccentColor: Int, Codable, Equatable, CaseIterable, Identifiable {
    case red = 1
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case blue
    case indigo
    case purple
    case pink
    case mono
    
    public var id: Int {
        return self.rawValue
    }
    
    public var title: String {
        switch self {
        case .red:
            return "red"
        case .orange:
            return "orange"
        case .yellow:
            return "yellow"
        case .green:
            return "green"
        case .mint:
            return "mint"
        case .teal:
            return "teal"
        case .cyan:
            return "cyan"
        case .blue:
            return "blue"
        case .indigo:
            return "indigo"
        case .purple:
            return "purple"
        case .pink:
            return "pink"
        case .mono:
            return "monochrome"
        }
    }
    
    public var color: Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .mint:
            return .mint
        case .teal:
            return .teal
        case .cyan:
            return .cyan
        case .blue:
            return .blue
        case .indigo:
            return .indigo
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .mono:
            return .primary
        }
    }
}

