import ComposableArchitecture
import MatchSettingsClient
import Models
import SwiftUI

public typealias MatchSettingsReducer = Reducer<MatchSettingsState, MatchSettingsAction, MatchSettingsEnvironment>

public struct MatchSettingsState: Equatable {
    public init(
        matchSettings: IdentifiedArrayOf<MatchSetting> = [],
        defaultSettings: MatchSetting = .init(
            id: .init(),
            createdDate: .now,
            isTrackingWorkout: true,
            isWinByTwo: true,
            name: "Standard",
            scoreLimit: 11,
            serveInterval: 2
        )
    ) {
        self.matchSettings = matchSettings
        self.defaultSettings = defaultSettings
    }
    
    var matchSettings: IdentifiedArrayOf<MatchSetting>
    var defaultSettings: MatchSetting
}

public enum MatchSettingsAction: Equatable {
    case setNavigation(selection: UUID?)
}

public struct MatchSettingsEnvironment {
    public init(
        settingsClient: MatchSettingsClient
    ) {
        self.settingsClient = settingsClient
    }
    
    var settingsClient: MatchSettingsClient
}

public let matchSettingsReducer = MatchSettingsReducer
{ state, action, environment in
    switch action {
    default:
        return .none
    }
}

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
        }
        .navigationTitle("Match Settings")
    }
}

struct MatchSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MatchSettingsView(
                store: Store(
                    initialState: MatchSettingsState(
                        matchSettings: [
                            .init(
                                id: .init(),
                                createdDate: .now,
                                isTrackingWorkout: true,
                                isWinByTwo: true,
                                name: "21",
                                scoreLimit: 21,
                                serveInterval: 5
                            )
                        ]
                    ),
                    reducer: matchSettingsReducer,
                    environment: .init(
                        settingsClient: .init(
                            fetch: { .none },
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
