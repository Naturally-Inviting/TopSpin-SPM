import Foundation
import ComposableArchitecture
import FileClient

public let userSettingsFileName = "user-settings"

public extension FileClient {
    func loadUserSettings() -> Effect<Result<UserSettings, NSError>, Never> {
        self.load(UserSettings.self, from: userSettingsFileName)
    }
    
    func saveUserSettings(
        userSettings: UserSettings, on queue: AnySchedulerOf<DispatchQueue>
    ) -> Effect<Never, Never> {
        self.save(userSettings, to: userSettingsFileName, on: queue)
    }
}
