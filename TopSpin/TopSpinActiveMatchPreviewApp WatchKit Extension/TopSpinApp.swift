import ComposableArchitecture
import SwiftUI
import WatchActiveMatchTabFeature

@main
struct ActiveMatchTabViewPreviewApp: App {
    let store: Store<ActiveMatchTabState, ActiveMatchTabAction>
    
    init() {
        self.store = Store(
            initialState: .init(
                workoutState: nil
            ),
            reducer: activeMatchTabReducer.debug(),
            environment: .init(
                healthKitClient: .live,
                mainQueue: .main
            )
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ActiveMatchTabView(
                store: store
            )
        }
    }
}
