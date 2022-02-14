#if os(watchOS)
import Foundation
import Combine
import ComposableArchitecture
import WatchConnectivity

public struct WatchConnectivityClient {
    
    public var activate: (AnyHashable) -> Effect<Action, Failure>
    public var isWatchAppInstalled: (AnyHashable) -> Effect<Bool, Never>
    public var isWCSessionSupported: () -> Effect<Bool, Never>
    
    public enum Action {
        case activationDidComplete(WCSessionActivationState, Error?)
        case sessionDidBecomeInactive
        case sessionDidDeactivate
        case didReceiveMessage([String : Any])
    }
    
    public enum Failure: Equatable, Error {
        case failed
    }
}

private var dependencies: [AnyHashable: WatchConnectivityDelegate] = [:]

private class WatchConnectivityDelegate: NSObject, WCSessionDelegate {
    
    let wcSession: WCSession
    
    let activationDidComplete: (WCSessionActivationState, Error?) -> Void
    let didReceiveMessage: ([String: Any]) -> Void
    
    init(
        activationDidComplete: @escaping (WCSessionActivationState, Error?) -> Void,
        didReceiveMessage: @escaping ([String: Any]) -> Void
    ) {
        wcSession = WCSession.default
        self.activationDidComplete = activationDidComplete
        self.didReceiveMessage = didReceiveMessage
        
        super.init()
        
        wcSession.delegate = self
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.activationDidComplete(activationState, error)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.didReceiveMessage(message)
    }
}

extension WatchConnectivityClient {
    
    public static var live: Self {
        return Self(
            activate: { id in
                .future { callback in
                    let delegate = WatchConnectivityDelegate(
                        activationDidComplete: { state, error in
                            callback(.success(.activationDidComplete(state, error)))
                        },
                        didReceiveMessage: { message in
                            callback(.success(.didReceiveMessage(message)))
                        }
                    )
                    
                    dependencies[id] = delegate
                    delegate.wcSession.activate()
                }
            },
            isWatchAppInstalled: { id in
                Effect(value: true) // This will always be true for the Watch.
            },
            isWCSessionSupported: {
                Effect(value: WCSession.isSupported())
            }
        )
    }
}

#endif
