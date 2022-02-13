import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct TopSpinApp: App {
    let store = Store(
        initialState: AppCoreState(),
        reducer: appCoreReducer.debug(),
        environment: AppCoreEnvironment(mainQueue: .main, matchClient: .live, watchConnectivityClient: .live)
    )
    
    lazy var viewStore = ViewStore(
        self.store,
        removeDuplicates: ==
    )
    
    var body: some Scene {
        WindowGroup {
            AppCoreView(store: store)
        }
    }
}
