import Combine
import UIKit
import ComposableArchitecture
import XCTestDynamicOverlay

public struct UIApplicationClient {
    public var exit: () -> Effect<Never, Never>
    public var alternateIconName: () -> String?
    public var open: (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) -> Effect<Bool, Never>
    public var openSettingsURLString: () -> String
    public var setAlternateIconName: (String?) -> Effect<Never, Error>
    public var supportsAlternateIcons: () -> Bool
}

@available(iOSApplicationExtension, unavailable)
public extension UIApplicationClient {
    static let live = Self(
        exit: {
            .fireAndForget {
                assertionFailure("Application did Exit.")
            }
        },
        alternateIconName: { UIApplication.shared.alternateIconName },
        open: { url, options in
                .future { callback in
                    UIApplication.shared.open(url, options: options) { bool in
                        callback(.success(bool))
                    }
                }
        },
        openSettingsURLString: { UIApplication.openSettingsURLString },
        setAlternateIconName: { iconName in
                .run { subscriber in
                    UIApplication.shared.setAlternateIconName(iconName) { error in
                        if let error = error {
                            subscriber.send(completion: .failure(error))
                        } else {
                            subscriber.send(completion: .finished)
                        }
                    }
                    return AnyCancellable {}
                }
        },
        supportsAlternateIcons: { UIApplication.shared.supportsAlternateIcons }
    )
}

public extension UIApplicationClient {
#if DEBUG
    static let failing = Self(
        exit: {
            return .failing("\(Self.self).exit is unimplemented")
        },
        alternateIconName: {
            XCTFail("\(Self.self).alternateIconName is unimplemented")
            return nil
        },
        open: { _, _ in .failing("\(Self.self).open is unimplemented") },
        openSettingsURLString: {
            XCTFail("\(Self.self).openSettingsURLString is unimplemented")
            return ""
        },
        setAlternateIconName: { _ in .failing("\(Self.self).setAlternateIconName is unimplemented") },
        supportsAlternateIcons: {
            XCTFail("\(Self.self).supportsAlternateIcons is unimplemented")
            return false
        }
    )
#endif
    
    static let noop = Self(
        exit: { .none },
        alternateIconName: { nil },
        open: { _, _ in .none },
        openSettingsURLString: { "settings://isowords/settings" },
        setAlternateIconName: { _ in .none },
        supportsAlternateIcons: { true }
    )
}
