import Combine
import ComposableArchitecture
import XCTest

@testable import UserSettingsFeature

extension UserSettingsEnvironment {
    static var failing: Self {
        Self(
            cloudKitClient: .noop,
            defaultSettingsClient: .init(defaultId: { nil }, setDefault: { _ in .none }),
            emailClient: .noop,
            fileClient: .noop,
            mainQueue: .failing,
            matchSettingsClient: .init(fetch: { .none }, create: { _ in .none}, delete: { _ in .none }),
            shareSheetClient: .noop,
            storeKitClient: .noop,
            uiApplicationClient: .noop,
            uiUserInterfaceStyleClient: .noop,
            userDefaults: .noop
        )
    }
}

class UserSettingsFeatureTests: XCTestCase {
    func testColorScheme() {
        let scheduler = DispatchQueue.test
        var environment: UserSettingsEnvironment = .failing
        
        environment.uiUserInterfaceStyleClient.setUserInterfaceStyle = { _ in .none }
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        environment.fileClient = .noop
        
        let store = TestStore(
            initialState: UserSettingsState(),
            reducer: userSettingsReducer,
            environment: environment
        )
        
        store.send(.set(\.$isColorSchemeNavigationActive, true)) {
            $0.colorScheme = .system
            $0.isColorSchemeNavigationActive = true
        }
        
        store.send(.set(\.$colorScheme, .light)) {
            $0.colorScheme = .light
        }
        
        store.send(.set(\.$isColorSchemeNavigationActive, false)) {
            $0.isColorSchemeNavigationActive = false
        }
        
        scheduler.run()
    }
}
