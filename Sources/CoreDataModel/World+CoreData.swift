import CoreDataStack
import World

extension CoreDataStack {
    fileprivate static var shared = CoreDataStack(model: topSpinModel)
}

#if DEBUG
fileprivate var coreDataClient: () -> CoreDataStack = { CoreDataStack.shared }
#else
fileprivate let coreDataClient: () -> CoreDataStack = { CoreDataStack.shared }
#endif

public extension World {
    var coreDataStack: () -> CoreDataStack {
        get {
            return coreDataClient
        }
        set {
            #if DEBUG
            coreDataClient = newValue
            #else
            return
            #endif
        }
    }
}
