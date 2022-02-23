import ComposableArchitecture
import SwiftUI

public struct WatchAppCoreView: View {
    let store: Store<WatchAppState, WatchAppAction>
    @ObservedObject var viewStore: ViewStore<WatchAppState, WatchAppAction>
    
    public init(
        store: Store<WatchAppState, WatchAppAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        TabView(selection: viewStore.binding(\.$selectedTabIndex)) {
            Text("Settings")
                .tag(1)
            Text("Match")
                .tag(2)
            Text("History")
                .tag(3)
        }
    }
}
