import CloudKitClient
import ComposableArchitecture
import ComposableHelpers
import DefaultSettingClient
import EmailClient
import FileClient
import MatchSettingsClient
import MatchSettingsFeature
import StoreKitClient
import ShareSheetClient
import SwiftUI
import SwiftUIHelpers
import UIApplicationClient
import UIUserInterfaceStyleClient
import UserDefaultsClient
import World

public typealias UserSettingsReducer = Reducer<UserSettingsState, UserSettingsAction, UserSettingsEnvironment>

public struct UserSettingsState: Equatable {
    public init(
        supportsAlternativeIcon: Bool = true,
        isSyncWithiCloudOn: Bool = true,
        matchSettingsState: MatchSettingsState? = nil,
        colorScheme: ColorScheme = .system,
        appIcon: AppIcon? = nil,
        accentColor: AccentColor = .blue,
        isColorSchemeNavigationActive: Bool = false,
        isAppIconNavigationActive: Bool = false,
        isAccentColorNavigationActive: Bool = false,
        isMatchSettingsNavigationActive: Bool = false
    ) {
        self.supportsAlternativeIcon = supportsAlternativeIcon
        self.isSyncWithiCloudOn = isSyncWithiCloudOn
        self.matchSettingsState = matchSettingsState
        self.colorScheme = colorScheme
        self.appIcon = appIcon
        self.accentColor = accentColor
        self.isColorSchemeNavigationActive = isColorSchemeNavigationActive
        self.isAppIconNavigationActive = isAppIconNavigationActive
        self.isAccentColorNavigationActive = isAccentColorNavigationActive
        self.isMatchSettingsNavigationActive = isMatchSettingsNavigationActive
    }
    
    public var supportsAlternativeIcon: Bool
    public var isSyncWithiCloudOn: Bool
    public var matchSettingsState: MatchSettingsState?
    @BindableState public var colorScheme: ColorScheme
    @BindableState public var appIcon: AppIcon?
    @BindableState public var accentColor: AccentColor
    @BindableState public var isColorSchemeNavigationActive: Bool
    @BindableState public var isAppIconNavigationActive: Bool
    @BindableState public var isAccentColorNavigationActive: Bool
    @BindableState public var isMatchSettingsNavigationActive: Bool
    
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
    case matchSettings(MatchSettingsAction)
    
    #if DEBUG
    case clearCache
    #endif
}

public struct UserSettingsEnvironment {
    public init(
        cloudKitClient: CloudKitClient,
        defaultSettingsClient: DefaultSettingClient,
        emailClient: EmailClient,
        fileClient: FileClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        matchSettingsClient: MatchSettingsClient,
        shareSheetClient: ShareSheetClient,
        storeKitClient: StoreKitClient,
        uiApplicationClient: UIApplicationClient,
        uiUserInterfaceStyleClient: UIUserInterfaceStyleClient,
        userDefaults: UserDefaultsClient
    ) {
        self.cloudKitClient = cloudKitClient
        self.defaultSettingsClient = defaultSettingsClient
        self.emailClient = emailClient
        self.fileClient = fileClient
        self.mainQueue = mainQueue
        self.matchSettingsClient = matchSettingsClient
        self.shareSheetClient = shareSheetClient
        self.storeKitClient = storeKitClient
        self.uiApplicationClient = uiApplicationClient
        self.userDefaults = userDefaults
        self.uiUserInterfaceStyleClient = uiUserInterfaceStyleClient
    }
    
    public var cloudKitClient: CloudKitClient
    public var defaultSettingsClient: DefaultSettingClient
    public var emailClient: EmailClient
    public var fileClient: FileClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var matchSettingsClient: MatchSettingsClient
    public var shareSheetClient: ShareSheetClient
    public var storeKitClient: StoreKitClient
    public var uiApplicationClient: UIApplicationClient
    public var uiUserInterfaceStyleClient: UIUserInterfaceStyleClient
    public var userDefaults: UserDefaultsClient
}

private let reducer = UserSettingsReducer
{ state, action, environment in
    switch action {
        
    #if DEBUG
    case .clearCache:
        return .concatenate(
            environment.userDefaults.clear()
                .fireAndForget(),
            environment.uiApplicationClient.exit()
                .fireAndForget()
        )
        
    #endif
        
    case let .iCloudSyncToggled(isOn):
        state.isSyncWithiCloudOn = isOn
        return .merge(
            environment.cloudKitClient.setCloudSync(isOn)
                .fireAndForget(),
            .fireAndForget {
                Current.setupContainer(isOn)
            }
        )
        
    case .binding(\.$isMatchSettingsNavigationActive):
        if state.isMatchSettingsNavigationActive {
            state.matchSettingsState = MatchSettingsState(accentColor: state.userSettings.accentColor.color)
        } else {
            state.matchSettingsState = nil
        }
        
        return .none
        
    case .binding(\.$colorScheme):
        return environment.uiUserInterfaceStyleClient.setUserInterfaceStyle(state.colorScheme.userInterfaceStyle)
            .fireAndForget()
        
    case .binding(\.$appIcon):
        return environment.uiApplicationClient
            .setAlternateIconName(state.appIcon?.rawValue)
            .fireAndForget()
        
    case .onAppear:
        state.supportsAlternativeIcon = environment.uiApplicationClient.supportsAlternateIcons()
        state.appIcon = environment.uiApplicationClient.alternateIconName()
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

public let userSettingsReducer: UserSettingsReducer =
.combine(
    matchSettingsReducer
        .optional()
        .pullback(
            state: \.matchSettingsState,
            action: /UserSettingsAction.matchSettings,
            environment: {
                MatchSettingsEnvironment(
                    defaultSettingsClient: $0.defaultSettingsClient,
                    mainQueue: $0.mainQueue,
                    settingsClient: $0.matchSettingsClient
                )
            }
        ),
    reducer
)

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
                footer: Text("Syncing with iCloud will make sure your data is on all your devices.")
            ) {
                NavigationLink(
                    "🏓  Match Settings",
                    isActive: viewStore.binding(\.$isMatchSettingsNavigationActive).removeDuplicates()
                ) {
                    IfLetStore(
                        self.store.scope(
                            state: \.matchSettingsState,
                            action: UserSettingsAction.matchSettings
                        ),
                        then: MatchSettingsView.init
                    )
                }
                
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
                            cloudKitClient: .noop,
                            defaultSettingsClient: .init(
                                defaultId: { nil },
                                setDefault: { _ in .none}
                            ),
                            emailClient: .noop,
                            fileClient: .noop,
                            mainQueue: .main,
                            matchSettingsClient: .init(
                                fetch: { .none },
                                create: { _ in .none },
                                delete: { _ in .none }
                            ),
                            shareSheetClient: .noop,
                            storeKitClient: .noop,
                            uiApplicationClient: .noop,
                            uiUserInterfaceStyleClient: .noop,
                            userDefaults: .noop
                        )
                    )
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
