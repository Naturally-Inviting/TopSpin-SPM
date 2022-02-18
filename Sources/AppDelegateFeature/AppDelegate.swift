import UIKit
import ComposableArchitecture
import FileClient
import UserSettingsFeature
import UIUserInterfaceStyleClient

public typealias AppDelegateReducer = Reducer<UserSettings, AppDelegateAction, AppDelegateEnvironment>

public enum AppDelegateAction: Equatable {
    case didFinishLaunching
    case userSettingsLoaded(Result<UserSettings, NSError>)
}

public struct AppDelegateEnvironment {
    var fileClient: FileClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uiUserInterfaceStyleClient: UIUserInterfaceStyleClient
    
    public init(
        fileClient: FileClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        uiUserInterfaceStyleClient: UIUserInterfaceStyleClient
    ) {
        self.fileClient = fileClient
        self.mainQueue = mainQueue
        self.uiUserInterfaceStyleClient = uiUserInterfaceStyleClient
    }
}

public let appDelegateReducer = AppDelegateReducer
{ state, action, environment in
    switch action {
    case .didFinishLaunching:
        return environment.fileClient.loadUserSettings()
          .map(AppDelegateAction.userSettingsLoaded)
        
    case let .userSettingsLoaded(result):
        state = (try? result.get()) ?? state
        
        // NB: This is necessary because UIKit needs at least one tick of the run loop before we
        //     can set the user interface style.
        return environment.uiUserInterfaceStyleClient.setUserInterfaceStyle(state.colorScheme.userInterfaceStyle)
            .subscribe(on: environment.mainQueue)
            .fireAndForget()
    }
}
