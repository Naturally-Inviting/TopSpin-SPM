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

public struct UserSettingsView: View {
    let store: Store<UserSettingsState, UserSettingsAction>
    @ObservedObject var viewStore: ViewStore<UserSettingsState, UserSettingsAction>
    
    public init(
        store: Store<UserSettingsState, UserSettingsAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        List {
            Section(
                footer:
                    Text("Syncing with iCloud will make sure your data is on all your devices.")
            ) {
                
                Toggle(isOn: viewStore.binding(
                    get: \.isSyncWithiCloudOn,
                    send: UserSettingsAction.iCloudSyncToggled(isOn:)
                )) {
                    HStack {
                        Image(systemName: "icloud")
                            .foregroundColor(viewStore.accentColor.color)
                        Text("iCloud Sync")
                    }
                }
                
            }
            .textCase(nil)
            
            Section(
                header:
                    Text("Theme")
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                        .padding(.leading, -16)
            ) {
                NavigationLink(isActive: viewStore.binding(\.$isAccentColorNavigationActive).removeDuplicates()) {
                    AccentColorPickerView(accentColor: viewStore.binding(\.$accentColor))
                } label: {
                    HStack {
                        Image(systemName: "paintpalette")
                            .foregroundColor(viewStore.accentColor.color)
                        Text("Accent Color")
                        Spacer()
                        Text(viewStore.accentColor.title.capitalized)
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink(isActive: viewStore.binding(\.$isColorSchemeNavigationActive).removeDuplicates()) {
                    ColorSchemePickerView(colorScheme: viewStore.binding(\.$colorScheme))
                } label: {
                    HStack {
                        Image(systemName: "paintbrush.pointed")
                            .foregroundColor(viewStore.accentColor.color)
                        Text("Theme")
                        Spacer()
                        Text(viewStore.colorScheme.title)
                            .foregroundColor(.secondary)
                    }
                }
                
                if viewStore.supportsAlternativeIcon {
                    NavigationLink(isActive: viewStore.binding(\.$isAppIconNavigationActive).removeDuplicates()) {
                        AppIconPickerView(appIcon: viewStore.binding(\.$appIcon))
                    } label: {
                        HStack {
                            Image(systemName: "app")
                                .foregroundColor(viewStore.accentColor.color)
                            Text("App Icon")
                            Spacer()
                        }
                    }
                }
            }
            .textCase(nil)
            
            Section(header:
                Text("Support TopSpin")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(.leading, -16)
            ) {
                Button("Rate TopSpin on the App Store", action: { viewStore.send(.rateAppTapped) })
                Button("Recommend TopSpin to a Friend", action: { viewStore.send(.shareAppTapped) })
            }
            .textCase(nil)
            
            Section {
                NavigationLink("Terms of Service", destination: Text("Terms"))
                NavigationLink("Privacy", destination: Text("Privacy"))
            }
            .textCase(nil)
            
            Section {
                Button(action: { viewStore.send(.helpAndSupportTapped) }) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(viewStore.accentColor.color)
                        Text("Help and Support")
                            .foregroundColor(.primary)
                    }
                }
            }
            .textCase(nil)
            
            #if DEBUG
            Section(header:
                Text("Developer Settings")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(.leading, -16)
            ) {
                Button(action: { viewStore.send(.clearCache) }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear Cache")
                    }
                    .foregroundColor(.red)
                }
            }
            .textCase(nil)
            #endif
        }
        .navigationTitle("Settings")
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                UserSettingsView(
                    store: Store(
                        initialState: UserSettingsState(),
                        reducer: userSettingsReducer,
                        environment: .init(
                            applicationClient: .noop,
                            uiUserInterfaceStyleClient: .noop,
                            fileClient: .noop,
                            mainQueue: .main,
                            userDefaults: .noop,
                            storeKitClient: .noop,
                            shareSheetClient: .noop,
                            emailClient: .noop,
                            cloudKitClient: .noop
                        )
                    )
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
