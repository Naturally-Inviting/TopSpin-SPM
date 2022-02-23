import ComposableArchitecture
import DefaultSettingClient
import MatchSettingsClient
import Models
import SwiftUI
import SwiftUIHelpers

public typealias MatchSettingsReducer = Reducer<MatchSettingsState, MatchSettingsAction, MatchSettingsEnvironment>

public struct MatchSettingsState: Equatable {
    public init(
        defaultSettingsId: UUID? = nil,
        matchSettings: IdentifiedArrayOf<MatchSetting> = [],
        standardSettings: MatchSetting = .init(
            id: .init(),
            createdDate: .now,
            isTrackingWorkout: true,
            isWinByTwo: true,
            name: "Standard",
            scoreLimit: 11,
            serveInterval: 2
        ),
        addSettingsState: AddMatchSettingsState? = nil,
        isAddSettingsNavigationActive: Bool = false,
        accentColor: Color = .blue
    ) {
        self.defaultSettingsId = defaultSettingsId
        self.matchSettings = matchSettings
        self.standardSettings = standardSettings
        self.addSettingsState = addSettingsState
        self.isAddSettingsNavigationActive = isAddSettingsNavigationActive
        self.accentColor = accentColor
    }
    
    var accentColor: Color
    var defaultSettingsId: UUID?
    var matchSettings: IdentifiedArrayOf<MatchSetting>
    var standardSettings: MatchSetting
    var addSettingsState: AddMatchSettingsState?
    var isAddSettingsNavigationActive: Bool
}

public enum MatchSettingsAction: Equatable {
    case viewLoaded
    case setNavigation(selection: UUID?)
    case settingsResponse(Result<[MatchSetting], MatchSettingsClient.Failure>)
    case addMatchSettings(AddMatchSettingsAction)
    case setAddSettingsNavigationActive(isActive: Bool)
}

public struct MatchSettingsEnvironment {
    public init(
        defaultSettingsClient: DefaultSettingClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        settingsClient: MatchSettingsClient
    ) {
        self.defaultSettingsClient = defaultSettingsClient
        self.mainQueue = mainQueue
        self.settingsClient = settingsClient
    }
    
    var defaultSettingsClient: DefaultSettingClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var settingsClient: MatchSettingsClient
}

private let reducer = MatchSettingsReducer
{ state, action, environment in
    switch action {
    case let .addMatchSettings(.saveSettingsResponse(.success(settings))):
        state.matchSettings.append(settings)
        state.isAddSettingsNavigationActive = false
        state.addSettingsState = nil
        return .none
        
    case .setAddSettingsNavigationActive(isActive: false):
        state.addSettingsState = nil
        state.isAddSettingsNavigationActive = false
        return .none
        
    case .setAddSettingsNavigationActive(isActive: true):
        state.addSettingsState = .init()
        state.isAddSettingsNavigationActive = true
        return .none
        
    case let .settingsResponse(.failure(error)):
        return .none
        
    case let .settingsResponse(.success(settings)):
        state.matchSettings = IdentifiedArrayOf<MatchSetting>(uniqueElements: settings)
        return .none
        
    case .viewLoaded:
        if let defaultSettingId = environment.defaultSettingsClient.defaultId() {
            state.defaultSettingsId = defaultSettingId
        }
        
        return environment.settingsClient.fetch()
            .receive(on: environment.mainQueue)
            .catchToEffect(MatchSettingsAction.settingsResponse)
    default:
        return .none
    }
}

public let matchSettingsReducer: MatchSettingsReducer =
.combine(
    addMatchSettingsReducer
        .optional()
        .pullback(
            state: \.addSettingsState,
            action: /MatchSettingsAction.addMatchSettings,
            environment: {
                AddMatchSettingsEnvironment(
                    defaultSettingsClient: $0.defaultSettingsClient,
                    mainQueue: $0.mainQueue,
                    settingsClient: $0.settingsClient
                )
            }
        ),
    reducer
)

public struct MatchSettingsView: View {
    let store: Store<MatchSettingsState, MatchSettingsAction>
    @ObservedObject var viewStore: ViewStore<MatchSettingsState, MatchSettingsAction>
    
    public init(
        store: Store<MatchSettingsState, MatchSettingsAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        List {
            if !viewStore.matchSettings.isEmpty {
                Section(
                    header: Text("My Settings")
                ) {
                    ForEach(viewStore.matchSettings) { settings in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(settings.name)
                                
                                if settings.id == viewStore.defaultSettingsId {
                                    Text("Default")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .textCase(nil)
            }
            
            Section(
                header: Text("Standard Settings")
            ) {
                VStack(alignment: .leading) {
                    Text("Standard")
                    Text("Standard Match to 11")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .textCase(nil)
            
            NavigationLink(
                "Add New",
                isActive: viewStore.binding(
                    get: \.isAddSettingsNavigationActive,
                    send: MatchSettingsAction.setAddSettingsNavigationActive(isActive:)
                )
                .removeDuplicates()
            ) {
                IfLetStore(
                    self.store.scope(
                        state: \.addSettingsState,
                        action: MatchSettingsAction.addMatchSettings
                    ),
                    then: AddMatchSettingsView.init
                )
            }
            .foregroundColor(viewStore.accentColor)
        }
        .onAppear {
            viewStore.send(.viewLoaded)
        }
        .navigationTitle("Match Settings")
    }
}

struct MatchSettingsView_Previews: PreviewProvider {
    
    static let id = UUID()
    
    static var previews: some View {
        NavigationView {
            MatchSettingsView(
                store: Store(
                    initialState: MatchSettingsState(
                        defaultSettingsId: id,
                        matchSettings: []
                    ),
                    reducer: matchSettingsReducer,
                    environment: .init(
                        defaultSettingsClient: .live(),
                        mainQueue: .main,
                        settingsClient: .init(
                            fetch: {
                                Effect(value: [
                                    .init(
                                        id: id,
                                        createdDate: .now,
                                        isTrackingWorkout: true,
                                        isWinByTwo: true,
                                        name: "21",
                                        scoreLimit: 21,
                                        serveInterval: 5
                                    )
                                ])
                                .eraseToEffect()
                            },
                            create: { _ in .none },
                            delete: { _ in .none }
                        )
                    )
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
