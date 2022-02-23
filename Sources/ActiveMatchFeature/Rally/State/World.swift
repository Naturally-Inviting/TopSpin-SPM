import Foundation

internal struct World {
    var date = { Date() }
    var uuid = { UUID() }
}

#if DEBUG
var Current = World()
#else
let Current = World()
#endif
