import WatchAppFeature
import ComposableArchitecture
import SwiftUI

@main
struct TopSpinApp: App {

    @Environment(\.scenePhase) var scenePhase

    let store: Store<WatchAppState, WatchAppAction>
    var viewStore: ViewStore<WatchAppState, WatchAppAction>

    init() {
        self.store = Store(
            initialState: WatchAppState(),
            reducer: watchAppCoreReducer.debug(),
            environment: .live
        )

        self.viewStore = ViewStore(
            self.store,
            removeDuplicates: ==
        )
    }
        
    var body: some Scene {
        WindowGroup {
            WatchAppCoreView(store: store)
                .onChange(of: scenePhase) { newValue in
                    viewStore.send(.scenePhaseChanged(newValue))
                }
        }
    }
}
