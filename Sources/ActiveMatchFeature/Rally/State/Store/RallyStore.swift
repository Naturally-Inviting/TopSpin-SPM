import SwiftUI

@available(watchOS 6.0, *)
@available(iOS 13.0, *)
public final class RallyStore: ObservableObject {
    
    @Published public private(set) var state: RallyState
    public private(set) var environment: RallyEnvironment
    
    public init(_ state: RallyState, _ environment: RallyEnvironment) {
        self.state = state
        self.environment = environment
    }
    
    public func dispatch(action: RallyAction) {
        state = rallyGameReducer(state, action)
    }
}
