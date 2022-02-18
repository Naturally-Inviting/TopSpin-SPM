import AppFeature
import ComposableArchitecture
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(
        initialState: AppCoreState(),
        reducer: appCoreReducer.debug(),
        environment: .live
    )
    
    lazy var viewStore = ViewStore(
        self.store,
        removeDuplicates: ==
    )
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        self.viewStore.send(.appDelegate(.didFinishLaunching))
        return true
    }
}

@main
struct TopSpinApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            AppCoreView(store: appDelegate.store)
                .onChange(of: scenePhase) { newPhase in
                    self.appDelegate.viewStore.send(.didChangeScenePhase(scenePhase: newPhase))
                }
        }
    }
}
