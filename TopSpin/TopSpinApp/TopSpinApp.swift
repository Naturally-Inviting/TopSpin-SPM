import AppFeature
import ComposableArchitecture
import SwiftUI

//private(set) var globalViewStore: ViewStore<AppCoreState, AppCoreAction>!

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(
        initialState: AppCoreState(),
        reducer: appCoreReducer.debug(),
        environment: AppCoreEnvironment(mainQueue: .main, matchClient: .live, watchConnectivityClient: .live)
    )
    
    lazy var viewStore = ViewStore(
        self.store,
        removeDuplicates: ==
    )
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
//        globalViewStore = self.viewStore
        
//        self.viewStore.send(.appDelegate(.didFinishLaunching))
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
