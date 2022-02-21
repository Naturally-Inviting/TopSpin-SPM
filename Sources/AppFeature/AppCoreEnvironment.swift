import CloudKitClient
import ComposableArchitecture
import DefaultSettingClient
import EmailClient
import FileClient
import Foundation
import MatchClient
import StoreKitClient
import ShareSheetClient
import UIApplicationClient
import UIUserInterfaceStyleClient
import UserDefaultsClient
import WatchConnectivityClient
import MatchSettingsClient

public struct AppCoreEnvironment {
    
    public init(
        cloudKitClient: CloudKitClient,
        defaultSettingsClient: DefaultSettingClient,
        emailClient: EmailClient,
        fileClient: FileClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        matchClient: MatchClient,
        matchSettingsClient: MatchSettingsClient,
        storeKitClient: StoreKitClient,
        shareSheetClient: ShareSheetClient,
        watchConnectivityClient: WatchConnectivityClient,
        uiApplicationClient: UIApplicationClient,
        uiUserInterfaceStyleClient: UIUserInterfaceStyleClient,
        userDefaults: UserDefaultsClient
    ) {
        self.cloudKitClient = cloudKitClient
        self.defaultSettingsClient = defaultSettingsClient
        self.emailClient = emailClient
        self.fileClient = fileClient
        self.mainQueue = mainQueue
        self.matchClient = matchClient
        self.matchSettingsClient = matchSettingsClient
        self.storeKitClient = storeKitClient
        self.shareSheetClient = shareSheetClient
        self.watchConnectivityClient = watchConnectivityClient
        self.uiApplicationClient = uiApplicationClient
        self.uiUserInterfaceStyleClient = uiUserInterfaceStyleClient
        self.userDefaults = userDefaults
    }
   
    var cloudKitClient: CloudKitClient
    var defaultSettingsClient: DefaultSettingClient
    var emailClient: EmailClient
    var fileClient: FileClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var matchClient: MatchClient
    var matchSettingsClient: MatchSettingsClient
    var storeKitClient: StoreKitClient
    var shareSheetClient: ShareSheetClient
    var watchConnectivityClient: WatchConnectivityClient
    var uiApplicationClient: UIApplicationClient
    var uiUserInterfaceStyleClient: UIUserInterfaceStyleClient
    var userDefaults: UserDefaultsClient
}

public extension AppCoreEnvironment {
    static var live: Self {
        Self(
            cloudKitClient: .live,
            defaultSettingsClient: .live,
            emailClient: .live,
            fileClient: .live,
            mainQueue: .main,
            matchClient: .live,
            matchSettingsClient: .live,
            storeKitClient: .live,
            shareSheetClient: .live,
            watchConnectivityClient: .live,
            uiApplicationClient: .live,
            uiUserInterfaceStyleClient: .live,
            userDefaults: .live()
        )
    }
}
