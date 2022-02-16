import StoreKit
import ComposableArchitecture

public struct StoreKitClient {
    public var requestReview: () -> Effect<Never, Never>
}

public extension StoreKitClient {
    static let live: Self = Self(
        requestReview: {
            .fireAndForget {
                let keyWindow = UIApplication.shared.connectedScenes
                            .first(where: { $0 is UIWindowScene })
                            .flatMap({ $0 as? UIWindowScene })
                        
                if let keyWindow = keyWindow {
                    SKStoreReviewController.requestReview(in: keyWindow)
                }
            }
        }
    )
}

public extension StoreKitClient {
    static let noop: Self = Self(
        requestReview: {
            return .none
        }
    )
}
