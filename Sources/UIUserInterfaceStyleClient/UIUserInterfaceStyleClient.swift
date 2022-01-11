import UIKit
import ComposableArchitecture

public struct UIUserInterfaceStyleClient {
    public var setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
    public var getUserInterfaceStyle: () -> Effect<UIUserInterfaceStyle, Never>
}

public extension UIUserInterfaceStyleClient {
    static let noop = Self(
        setUserInterfaceStyle: { _ in .none },
        getUserInterfaceStyle: { .none }
    )
    
    static let live = Self(
        setUserInterfaceStyle: { userInterfaceStyle in
                .fireAndForget {
                    setUserInterfaceStyle(userInterfaceStyle)
                }
        },
        getUserInterfaceStyle: {
            let style = UITraitCollection.current.userInterfaceStyle
            return Effect(value: style)
        }
    )
    
    static let failing = Self(
        setUserInterfaceStyle: { _ in
            .failing("UIUserInterfaceStyleClient.setUserInterfaceStyle")
        },
        getUserInterfaceStyle: {
            .failing("UIUserInterfaceStyleClient.getUserInterfaceStyle")
        }
    )
    
    static func setUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        let windows = UIApplication.shared.connectedScenes
                    .first(where: { $0 is UIWindowScene })
                    .flatMap({ $0 as? UIWindowScene })?.windows
        
        windows?.forEach {
            $0.overrideUserInterfaceStyle = style
        }
    }
}
