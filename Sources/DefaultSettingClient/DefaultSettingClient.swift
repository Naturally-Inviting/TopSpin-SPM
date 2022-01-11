import CloudKit
import ComposableArchitecture
import Foundation

public struct DefaultSettingClient {
    public var defaultId: () -> UUID?
    public var setDefault: (UUID) -> Effect<Never, Never>
}

// TODO: Move this logic to App Core. Make into Unit Testable with Cloud + User Default clients.
public extension DefaultSettingClient {
    static var live: Self {
        Self(
            defaultId: {
                guard let savedUserDefault = UserDefaults.standard.string(forKey: defaultMatchSettingsKey) else { return nil }
                let savedCloudDefault = NSUbiquitousKeyValueStore.default.string(forKey: defaultMatchSettingsKey)
                
                // If there is no value in the cloud, then save it.
                if savedCloudDefault == nil {
                    NSUbiquitousKeyValueStore.default.setValue(savedUserDefault, forKey: defaultMatchSettingsKey)
                }
                
                // If the two items are different, return the cloud value.
                if savedUserDefault != savedCloudDefault {
                    UserDefaults.standard.setValue(savedCloudDefault, forKey: defaultMatchSettingsKey)
                }
                
                guard let id = UUID(uuidString: savedUserDefault) else { return nil }
                
                return id
            },
            setDefault: { id in
                .fireAndForget {
                    UserDefaults.standard.setValue(id.uuidString, forKey: defaultMatchSettingsKey)
                    NSUbiquitousKeyValueStore.default.setValue(id.uuidString, forKey: defaultMatchSettingsKey)
                }
            }
        )
    }
}

let defaultMatchSettingsKey = ""
