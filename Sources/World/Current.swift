import Foundation

#if DEBUG
public var Current = World()
#else
public let Current = World()
#endif

public struct World {
    public var date: () -> Date = { .init() }
    public var uuid: () -> UUID = { .init() }
    
    public var calendar = Calendar.autoupdatingCurrent
    public var locale = Locale.autoupdatingCurrent
    public var timeZone = TimeZone.autoupdatingCurrent
}

public extension World {
    func dateFormatter(
        dateStyle: DateFormatter.Style = .none,
        timeStyle: DateFormatter.Style = .none
    )
    -> DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        
        formatter.calendar = self.calendar
        formatter.locale = self.locale
        formatter.timeZone = self.timeZone
        
        return formatter
    }
}
