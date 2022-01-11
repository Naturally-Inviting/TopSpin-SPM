import Foundation
import ComposableArchitecture

struct UserDefaultsKey {
    static let didFinishOnboardingKey = "didFinishOnboardingKey"
    static let defaultMatchSettingsKey = "defaultMatchSettingsKey"
}

public struct UserDefaultsClient {
    public var boolForKey: (String) -> Bool
    public var stringForKey: (String) -> String?
    public var dataForKey: (String) -> Data?
    public var doubleForKey: (String) -> Double
    public var integerForKey: (String) -> Int
    public var remove: (String) -> Effect<Never, Never>
    public var setBool: (Bool, String) -> Effect<Never, Never>
    public var setValue: (Any, String) -> Effect<Never, Never>
    public var setData: (Data?, String) -> Effect<Never, Never>
    public var setDouble: (Double, String) -> Effect<Never, Never>
    public var setInteger: (Int, String) -> Effect<Never, Never>
    public var clear: () -> Effect<Never, Never>
    
    public var hasShownFirstLaunchOnboarding: Bool {
        self.boolForKey(UserDefaultsKey.didFinishOnboardingKey)
    }
    
    public func setHasShownFirstLaunchOnboarding(_ bool: Bool) -> Effect<Never, Never> {
        self.setBool(bool, UserDefaultsKey.didFinishOnboardingKey)
    }
    
    public var defaultSettingsId: UUID? {
        guard let savedUserDefault = self.stringForKey(UserDefaultsKey.defaultMatchSettingsKey) else { return nil }
        guard let id = UUID(uuidString: savedUserDefault) else { return nil }
        return id
    }
    
    public func setDefaultMatchSettingId(_ id: UUID) -> Effect<Never, Never> {
        self.setValue(id.uuidString, UserDefaultsKey.defaultMatchSettingsKey)
    }
}
