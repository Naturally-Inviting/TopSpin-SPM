import ComposableArchitecture
import DateExtension
import Models
import SwiftUI
import World

public struct MonthlySummaryState: Equatable {
    public init(
        matches: [Match],
        selectedSummary: Identified<MatchSummary.ID, MatchSummary>? = nil
    ) {
        let summary = Self.matchSummary(from: matches)
        self.matchSummary = IdentifiedArrayOf<MatchSummary>(uniqueElements: summary)
        self.selectedSummary = selectedSummary
    }
    
    internal var matchSummary: IdentifiedArrayOf<MatchSummary>
    internal var selectedSummary: Identified<MatchSummary.ID, MatchSummary>?
    
    internal static func matchSummary(from matches: [Match]) -> [MatchSummary] {
        let groupedMatches = matches.groupedBy(dateComponents: [.month], dateMap: { $0.date })
        var summaryList = [MatchSummary]()
        
        groupedMatches.forEach { date, matches in
            
            var totalWins = 0
            var totalLoses = 0
            var totalCalories = 0
            var totalHeartRate = 0
            var totalHeartEntries = 0
            
            matches.forEach { match in
                if match.playerScore > match.opponentScore {
                    totalWins += 1
                } else {
                    totalLoses += 1
                }
                
                totalCalories += match.workout?.activeCalories ?? 0
                totalHeartRate += match.workout?.heartRateAverage ?? 0
                totalHeartEntries += match.workout?.heartRateAverage != nil ? 1 : 0
            }
            
            let totalEntries = max(1, totalHeartEntries) // So that you cannot divide by 0
            let heartAverage = Int(totalHeartRate/totalEntries)
            let summary = MatchSummary(
                id: Current.uuid(),
                dateRange: date,
                wins: totalWins,
                loses: totalLoses,
                calories: totalCalories,
                heartRateAverage: heartAverage,
                matches: matches
            )
            
            let calendar = Current.calendar
            let componentDate = calendar.date(from: date)

            if componentDate?.isInThisMonth ?? false || componentDate?.isInThePast ?? false {
                summaryList.append(summary)
            }
        }
        
        summaryList.sort(by: { $0.dateRange > $1.dateRange })
        
        return summaryList
    }
}

public enum MonthlySummaryAction {
    case setSelectedMatch(selection: MatchSummary?)
}

public struct MonthlySummaryEnvironment {
}
