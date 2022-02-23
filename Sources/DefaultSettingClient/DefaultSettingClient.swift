import CloudKit
import ComposableArchitecture
import Foundation

/// Defaults for Match Settings
public struct DefaultSettingClient {
    public init(
        defaultId: @escaping () -> UUID?,
        setDefault: @escaping (UUID) -> Effect<Never, Never>
    ) {
        self.defaultId = defaultId
        self.setDefault = setDefault
    }
    
    public var defaultId: () -> UUID?
    public var setDefault: (UUID) -> Effect<Never, Never>
}

// TODO: Move this logic to App Core. Make into Unit Testable with Cloud + User Default clients.
extension DefaultSettingClient {
    public static func live(
        userDefaults: UserDefaults = UserDefaults(suiteName: "group.topspin")!
    ) -> Self {
        Self(
            defaultId: {
                guard let savedUserDefault = userDefaults.string(forKey: defaultMatchSettingsKey)
                else { return nil }
                #if os(iOS)
                let savedCloudDefault = NSUbiquitousKeyValueStore.default.string(forKey: defaultMatchSettingsKey)
                
                // If there is no value in the cloud, then save it.
                if savedCloudDefault == nil {
                    NSUbiquitousKeyValueStore.default.set(savedUserDefault, forKey: defaultMatchSettingsKey)
                }
                
                // If the two items are different, return the cloud value.
                if savedUserDefault != savedCloudDefault && savedCloudDefault != nil {
                    userDefaults.setValue(savedCloudDefault, forKey: defaultMatchSettingsKey)
                }
                #endif
                
                guard let id = UUID(uuidString: savedUserDefault)
                else { return nil }
                
                return id
            },
            setDefault: { id in
                .fireAndForget {
                    userDefaults.setValue(id.uuidString, forKey: defaultMatchSettingsKey)
                    #if os(iOS)
                    NSUbiquitousKeyValueStore.default.set(id.uuidString, forKey: defaultMatchSettingsKey)
                    #endif
                }
            }
        )
    }
}

let defaultMatchSettingsKey = "defaultMatchSettingsKey"
