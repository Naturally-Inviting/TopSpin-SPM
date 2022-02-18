import Foundation

public struct WatchConnectivityState: Equatable {
    public var isWatchAppInstalled = false
    public var isWCSessionSupported = false
    
    public init(
        isWatchAppInstalled: Bool = false,
        isWCSessionSupported: Bool = false
    ) {
        self.isWatchAppInstalled = isWatchAppInstalled
        self.isWCSessionSupported = isWCSessionSupported
    }
}
