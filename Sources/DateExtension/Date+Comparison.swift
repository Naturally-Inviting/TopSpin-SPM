import Foundation
import World

// MARK: - Date + Comparison

public extension Date {

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = Current.calendar) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Current.calendar.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Current.date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Current.date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Current.date()) }

    var isInYesterday: Bool { Current.calendar.isDateInYesterday(self) }
    var isInToday:     Bool { Current.calendar.isDateInToday(self) }
    var isInTomorrow:  Bool { Current.calendar.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Current.date() }
    var isInThePast:   Bool { self < Current.date() }
}
