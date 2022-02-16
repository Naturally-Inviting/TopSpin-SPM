import ComposableArchitecture
import SwiftUI
import MatchHistoryListFeature
import UserSettingsFeature

#if os(iOS)
public struct AppCoreView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    let store: Store<AppCoreState, AppCoreAction>
    @ObservedObject var viewStore: ViewStore<AppCoreState, AppCoreAction>
    
    public init(
        store: Store<AppCoreState, AppCoreAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var sideBarRootView: some View {
        MatchHistoryListView(
            store: store.scope(
                state: \.matchHistoryState,
                action: AppCoreAction.matchHistory
            )
        )
    }
    
    var sideBarRootNavigation: some View {
        List {
            NavigationLink(
                isActive: viewStore.binding(\.$isMatchHistoryNavigationActive),
                destination: { sideBarRootView }
            ) {
                Text("Match History")
            }
                        
            NavigationLink(
                isActive: viewStore.binding(\.$isSettingsNavigationActive),
                destination: { Text("settings-view") }
            ) {
                Text("Settings")
            }
        }
        .navigationTitle("Top Spin")
    }
    
    public var body: some View {
        if horizontalSizeClass == .compact {
            TabView(selection: viewStore.binding(\.$selectedTabIndex)) {
                NavigationView {
                    MatchHistoryListView(
                        store: store.scope(
                            state: \.matchHistoryState,
                            action: AppCoreAction.matchHistory
                        )
                    )
                }
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("History")
                }
                .tag(0)
               
                NavigationView{
                    UserSettingsView(
                        store: store.scope(
                            state: \.userSettingsState,
                            action: AppCoreAction.userSettings
                        )
                    )
                }
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Settings")
                }
                .tag(1)
            }
        } else {
            NavigationView {
                sideBarRootNavigation
                sideBarRootView
            }
        }
    }
}

#elseif os(watchOS)
public struct AppCoreView: View {
    let store: Store<AppCoreState, AppCoreAction>
    @ObservedObject var viewStore: ViewStore<AppCoreState, AppCoreAction>
    
    public init(
        store: Store<AppCoreState, AppCoreAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        MatchHistoryListView(
            store: store.scope(
                state: \.matchHistoryState,
                action: AppCoreAction.matchHistory
            )
        )
    }
}
#endif
