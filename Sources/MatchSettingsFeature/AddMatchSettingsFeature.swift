import ComposableArchitecture
import MatchSettingsClient
import Models
import SwiftUI

public typealias AddMatchSettingsReducer = Reducer<AddMatchSettingsState, AddMatchSettingsAction, AddMatchSettingsEnvironment>

enum MatchScoreLimit: Int, CaseIterable {
    case eleven = 11
    case twentyOne = 21
}

enum MatchServeInterval: Int, CaseIterable {
    case everyTwo = 2
    case everyFive = 5
}

public struct AddMatchSettingsState: Equatable {
    public init(
        settingsName: String = "",
        scoreLimit: Int = 11,
        serveInterval: Int = 2,
        winByTwo: Bool = true,
        trackWorkoutData: Bool = true,
        setAsDefault: Bool = true
    ) {
        self.settingsName = settingsName
        self.scoreLimit = scoreLimit
        self.serveInterval = serveInterval
        self.winByTwo = winByTwo
        self.trackWorkoutData = trackWorkoutData
        self.setAsDefault = setAsDefault
    }
    
    @BindableState public var settingsName: String
    @BindableState public var scoreLimit: Int
    @BindableState public var serveInterval: Int
    @BindableState public var winByTwo: Bool
    @BindableState public var trackWorkoutData: Bool
    @BindableState public var setAsDefault: Bool
}

public enum AddMatchSettingsAction: Equatable, BindableAction {
    case binding(BindingAction<AddMatchSettingsState>)
    case saveSettings
}

public struct AddMatchSettingsEnvironment {
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        settingsClient: MatchSettingsClient
    ) {
        self.mainQueue = mainQueue
        self.settingsClient = settingsClient
    }
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var settingsClient: MatchSettingsClient
}

public let addMatchSettingsReducer = AddMatchSettingsReducer
{ state, action, environment in
    switch action {
    case .saveSettings:
        return .none
    default:
        return .none
    }
}
.binding()

public struct AddMatchSettingsView: View {
    let store: Store<AddMatchSettingsState, AddMatchSettingsAction>
    @ObservedObject var viewStore: ViewStore<AddMatchSettingsState, AddMatchSettingsAction>
    
    public init(
        store: Store<AddMatchSettingsState, AddMatchSettingsAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        Form {
            Section(
                footer: Text("Give your settings a custom name.")
            ) {
                TextField("My Settings", text: viewStore.binding(\.$settingsName))
            }
            
            Section {
                #if os(watchOS)
                Picker("Score Limit", selection: viewStore.binding(\.$scoreLimit)) {
                    ForEach(MatchScoreLimit.allCases, id: \.self.rawValue) { limit in
                        Text("\(limit.rawValue)")
                            .tag(limit.rawValue)
                    }
                }
                                
                Picker("Serve Interval", selection: viewStore.binding(\.$serveInterval)) {
                    ForEach(MatchServeInterval.allCases, id: \.self.rawValue) { interval in
                        Text("\(interval.rawValue)").tag(interval.rawValue)
                    }
                }
                #else
                VStack {
                    Text("What are you playing up to?")
                    Picker("Score Limit", selection: viewStore.binding(\.$scoreLimit)) {
                        ForEach(MatchScoreLimit.allCases, id: \.self.rawValue) { limit in
                            Text("\(limit.rawValue)")
                                .tag(limit.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                
                    Text("How often will you switch servers?")
                    Picker("Serve Interval", selection: viewStore.binding(\.$serveInterval)) {
                        ForEach(MatchServeInterval.allCases, id: \.self.rawValue) { interval in
                            Text("\(interval.rawValue)")
                                .tag(interval.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.vertical)
                #endif
            }
            
            Section {
                Toggle("Win by Two", isOn: viewStore.binding(\.$winByTwo))
                Toggle("Track Workout", isOn: viewStore.binding(\.$trackWorkoutData))
                Toggle("Set as Default", isOn: viewStore.binding(\.$setAsDefault))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save", action: { viewStore.send(.saveSettings) })
            }
        }
        .navigationTitle("New Settings")
    }
}

struct AddMatchSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddMatchSettingsView(
                store: Store(
                    initialState: AddMatchSettingsState(),
                    reducer: addMatchSettingsReducer,
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
