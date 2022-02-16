import Foundation

public struct UserSettings: Codable, Equatable {
    public init(
        colorScheme: ColorScheme = .system,
        appIcon: AppIcon? = nil,
        accentColor: AccentColor = .blue
    ) {
        self.colorScheme = colorScheme
        self.appIcon = appIcon
        self.accentColor = accentColor
    }
    
    public var colorScheme: ColorScheme
    public var appIcon: AppIcon?
    public var accentColor: AccentColor
}
