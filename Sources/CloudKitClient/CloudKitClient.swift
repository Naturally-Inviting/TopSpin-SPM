import CoreData
import ComposableArchitecture
import CoreDataStack

struct CloudKitKeys {
    static let iCloudSyncKey = "iCloudSyncKey"
    static let defaultMatchSettingsKey = "defaultMatchSettingsKey"
}

public struct CloudKitClient {
    public var boolForKey: (String) -> Bool
    public var stringForKey: (String) -> String?
    public var setBool: (Bool, String) -> Effect<Never, Never>
    public var setValue: (Any, String) -> Effect<Never, Never>
    
    public var isCloudSyncEnabled: Bool {
        self.boolForKey(CloudKitKeys.iCloudSyncKey)
    }
    
    public func setCloudSync(_ bool: Bool) -> Effect<Never, Never> {
        self.setBool(bool, CloudKitKeys.iCloudSyncKey)
    }
    
    public var defaultMatchSettingId: UUID? {
        guard let savedCloudDefault = self.stringForKey(CloudKitKeys.defaultMatchSettingsKey) else { return nil }
        guard let id = UUID(uuidString: savedCloudDefault) else { return nil }
        return id
    }
    
    public func setDefaultMatchSettingId(_ id: UUID) -> Effect<Never, Never> {
        self.setValue(id.uuidString, CloudKitKeys.defaultMatchSettingsKey)
    }
}

public extension CloudKitClient {
    static var noop: Self {
        Self(
            boolForKey: { _ in false },
            stringForKey: { _ in nil },
            setBool: { _, _ in .none },
            setValue: { _, _ in .none }
        )
    }
}

public extension CloudKitClient {
    static var live: Self {
        Self(
            boolForKey: { key in
                NSUbiquitousKeyValueStore.default.bool(forKey: key)

            },
            stringForKey: { key in
                NSUbiquitousKeyValueStore.default.string(forKey: key)
            },
            setBool: { value, key in
                    .fireAndForget {
                        NSUbiquitousKeyValueStore.default.set(value, forKey: key)
                    }
            },
            setValue: { value, key in
                    .fireAndForget {
                        NSUbiquitousKeyValueStore.default.set(value, forKey: key)
                    }
            }
        )
    }
}
