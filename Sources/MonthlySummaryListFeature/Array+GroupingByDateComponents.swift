import Foundation
import World

extension Array {
    /// Returns a dictionary of elements grouped by `Date`.
    /// Elements are grouped based on a set of `Calendar.Component`.
    ///
    /// - Important: The date returned as a key will only contain elements passed in via `dateComponents`.
    /// Example: With the components `[.month, .day]` for April 9, the date key would be "0001-04-09 00:00:00 +0000".
    /// Date's of the element in the dictionary will not be affected.
    ///
    /// - Parameters:
    ///     - dateComponents: Components by which date elements will be grouped.
    ///     - dateMap: Mapping to the `Date` of the object being grouped.
    ///
    /// - Returns: A `dictionary` of elements grouped by `Date`.
    ///
    /// - seealso: https://gist.github.com/karsonbraaten/a31f4ac1f26a20d03c2fe8dc4aca1491#file-grouped-by-date-components-swift
    ///
    public func groupedBy(dateComponents: Set<Calendar.Component>, dateMap: (Element) -> Date) -> [DateComponents: [Element]] {
        let initial: [DateComponents: [Element]] = [:]
        
        let groupedByDateComponents = reduce(into: initial) { dictionary, element in
            var calendar = Current.calendar
            calendar.timeZone = Current.timeZone

            let components = calendar.dateComponents(dateComponents, from: dateMap(element))
            
            dictionary[components, default: []] += [element]
        }
        
        return groupedByDateComponents
    }
}
