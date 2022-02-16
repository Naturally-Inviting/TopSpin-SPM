import CloudKitClient
import ComposableArchitecture
import ComposableHelpers
import EmailClient
import FileClient
import StoreKitClient
import ShareSheetClient
import SwiftUI
import SwiftUIHelpers
import UIApplicationClient
import UIUserInterfaceStyleClient
import UserDefaultsClient

typealias UserSettingsReducer = Reducer<UserSettingsState, UserSettingsAction, UserSettingsEnvironment>

public struct UserSettingsState: Equatable {
    public init(
        supportsAlternativeIcon: Bool = true,
        isSyncWithiCloudOn: Bool = true,
        colorScheme: ColorScheme = .system,
        appIcon: AppIcon? = nil,
        accentColor: AccentColor = .blue,
        isColorSchemeNavigationActive: Bool = false,
        isAppIconNavigationActive: Bool = false,
        isAccentColorNavigationActive: Bool = false
    ) {
        self.supportsAlternativeIcon = supportsAlternativeIcon
        self.isSyncWithiCloudOn = isSyncWithiCloudOn
        self.colorScheme = colorScheme
        self.appIcon = appIcon
        self.accentColor = accentColor
        self.isColorSchemeNavigationActive = isColorSchemeNavigationActive
        self.isAppIconNavigationActive = isAppIconNavigationActive
        self.isAccentColorNavigationActive = isAccentColorNavigationActive
    }
    
    public var supportsAlternativeIcon: Bool
    public var isSyncWithiCloudOn: Bool
    @BindableState public var colorScheme: ColorScheme
    @BindableState public var appIcon: AppIcon?
    @BindableState public var accentColor: AccentColor
    @BindableState public var isColorSchemeNavigationActive: Bool
    @BindableState public var isAppIconNavigationActive: Bool
    @BindableState public var isAccentColorNavigationActive: Bool
    
    public var userSettings: UserSettings {
        get {
            return UserSettings(
                colorScheme: colorScheme,
                appIcon: appIcon,
                accentColor: accentColor
            )
        }
        set {
            self.colorScheme = newValue.colorScheme
            self.appIcon = newValue.appIcon
            self.accentColor = newValue.accentColor
        }
    }
}

public enum UserSettingsAction: BindableAction, Equatable {
    case binding(BindingAction<UserSettingsState>)
    case iCloudSyncToggled(isOn: Bool)
    case onAppear
    case didTapClose
    case helpAndSupportTapped
    case rateAppTapped
    case shareAppTapped
    
    #if DEBUG
    case clearCache
    #endif
}

public struct UserSettingsEnvironment {
    public init(
        applicationClient: UIApplicationClient,
        uiUserInterfaceStyleClient: UIUserInterfaceStyleClient,
        fileClient: FileClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        userDefaults: UserDefaultsClient,
        storeKitClient: StoreKitClient,
        shareSheetClient: ShareSheetClient,
        emailClient: EmailClient,
        cloudKitClient: CloudKitClient
    ) {
        self.applicationClient = applicationClient
        self.uiUserInterfaceStyleClient = uiUserInterfaceStyleClient
        self.fileClient = fileClient
        self.mainQueue = mainQueue
        self.userDefaults = userDefaults
        self.storeKitClient = storeKitClient
        self.shareSheetClient = shareSheetClient
        self.emailClient = emailClient
        self.cloudKitClient = cloudKitClient
    }
    
    public var applicationClient: UIApplicationClient
    public var uiUserInterfaceStyleClient: UIUserInterfaceStyleClient
    public var fileClient: FileClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var userDefaults: UserDefaultsClient
    public var storeKitClient: StoreKitClient
    public var shareSheetClient: ShareSheetClient
    public var emailClient: EmailClient
    public var cloudKitClient: CloudKitClient
}

public let userSettingsReducer = UserSettingsReducer
{ state, action, environment in
    switch action {
        
    #if DEBUG
    case .clearCache:
        return .concatenate(
            environment.userDefaults.clear()
                .fireAndForget(),
            environment.applicationClient.exit()
                .fireAndForget()
        )
        
    #endif
        
    case let .iCloudSyncToggled(isOn):
        state.isSyncWithiCloudOn = isOn
        return environment.cloudKitClient.setCloudSync(isOn)
            .fireAndForget()
        
    case .binding(\.$colorScheme):
        return environment.uiUserInterfaceStyleClient.setUserInterfaceStyle(state.colorScheme.userInterfaceStyle)
            .fireAndForget()
        
    case .binding(\.$appIcon):
        return environment.applicationClient
            .setAlternateIconName(state.appIcon?.rawValue)
            .fireAndForget()
        
    case .onAppear:
        state.supportsAlternativeIcon = environment.applicationClient.supportsAlternateIcons()
        state.appIcon = environment.applicationClient.alternateIconName()
            .flatMap(AppIcon.init(rawValue:))
        state.isSyncWithiCloudOn = environment.cloudKitClient.isCloudSyncEnabled
        
        return .none
        
    case .helpAndSupportTapped:
        return environment.emailClient.sendEmail()
            .fireAndForget()
        
    default:
        return .none
    }
}
.binding()
.onChange(of: \.userSettings) { userSettings, _, _, environment in
    struct SaveDebounceId: Hashable {}

    return environment.fileClient
        .saveUserSettings(userSettings: userSettings, on: environment.mainQueue)
        .fireAndForget()
        .debounce(id: SaveDebounceId(), for: .seconds(1), scheduler: environment.mainQueue)
}

public struct AppSettingsView: View {
    public var body: some View {
        Text("hello")
    }
}

struct AppSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppSettingsView()
        }
    }
}
