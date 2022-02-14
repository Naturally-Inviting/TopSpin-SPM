import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct TopSpinApp: App {

    let store: Store<AppCoreState, AppCoreAction>
    var viewStore: ViewStore<AppCoreState, AppCoreAction>
    
    init() {
        self.store = Store(
            initialState: AppCoreState(),
            reducer: appCoreReducer.debug(),
            environment: AppCoreEnvironment(mainQueue: .main, matchClient: .live, watchConnectivityClient: .live)
        )
         
        self.viewStore = ViewStore(
            self.store,
            removeDuplicates: ==
        )
    }
        
    var body: some Scene {
        WindowGroup {
            AppCoreView(store: store)
                .onAppear {
                    self.viewStore.send(.didChangeScenePhase(scenePhase: .active))
                }
        }
    }
}