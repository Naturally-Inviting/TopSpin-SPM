import CloudKitClient
import ComposableArchitecture
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

public struct AppCoreEnvironment {
    
    public init(
        cloudKitClient: CloudKitClient,
        emailClient: EmailClient,
        fileClient: FileClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        matchClient: MatchClient,
        storeKitClient: StoreKitClient,
        shareSheetClient: ShareSheetClient,
        watchConnectivityClient: WatchConnectivityClient,
        uiApplicationClient: UIApplicationClient,
        uiUserInterfaceStyleClient: UIUserInterfaceStyleClient,
        userDefaults: UserDefaultsClient
    ) {
        self.cloudKitClient = cloudKitClient
        self.emailClient = emailClient
        self.fileClient = fileClient
        self.mainQueue = mainQueue
        self.matchClient = matchClient
        self.storeKitClient = storeKitClient
        self.shareSheetClient = shareSheetClient
        self.watchConnectivityClient = watchConnectivityClient
        self.uiApplicationClient = uiApplicationClient
        self.uiUserInterfaceStyleClient = uiUserInterfaceStyleClient
        self.userDefaults = userDefaults
    }
   
    var cloudKitClient: CloudKitClient
    var emailClient: EmailClient
    var fileClient: FileClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var matchClient: MatchClient
    var storeKitClient: StoreKitClient
    var shareSheetClient: ShareSheetClient
    var watchConnectivityClient: WatchConnectivityClient
    var uiApplicationClient: UIApplicationClient
    var uiUserInterfaceStyleClient: UIUserInterfaceStyleClient
    var userDefaults: UserDefaultsClient
}

public extension AppCoreEnvironment {
    var live: Self {
        Self(
            cloudKitClient: .live,
            emailClient: .live,
            fileClient: .live,
            mainQueue: .main,
            matchClient: .live,
            storeKitClient: .live,
            shareSheetClient: .live,
            watchConnectivityClient: .live,
            uiApplicationClient: .live,
            uiUserInterfaceStyleClient: .live,
            userDefaults: .live()
        )
    }
}
