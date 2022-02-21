import ComposableArchitecture
import DateExtension
import Models
import SwiftUI
import World

public typealias MonthlySummaryReducer = Reducer<MonthlySummaryState, MonthlySummaryAction, MonthlySummaryEnvironment>

public struct MonthlySummaryState: Equatable {
    public init(
        matches: [Match] = [],
        selectedSummary: Identified<MonthlySummary.ID, MonthlyDetailState>? = nil
    ) {
        let summary = Self.matchSummary(from: matches)
        self.monthlySummary = IdentifiedArrayOf<MonthlySummary>(uniqueElements: summary)
        self.selectedSummary = selectedSummary
    }
    
    internal var monthlySummary: IdentifiedArrayOf<MonthlySummary>
    internal var selectedSummary: Identified<MonthlySummary.ID, MonthlyDetailState>?
    
    internal static func matchSummary(from matches: [Match]) -> [MonthlySummary] {
        let groupedMatches = matches.groupedBy(dateComponents: [.month, .year], dateMap: { $0.date })
        var summaryList = [MonthlySummary]()
        
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
            let summary = MonthlySummary(
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

public enum MonthlySummaryAction: Equatable {
    case setNavigation(selection: UUID?)
}

public struct MonthlySummaryEnvironment {
    public init() {}
}

public let monthlySummaryReducer = MonthlySummaryReducer
{ state, action, environment in
    switch action {
    case let .setNavigation(selection: .some(id)):
        if let summary = state.monthlySummary[id: id] {
            state.selectedSummary = Identified(
                MonthlyDetailState(
                    summary: summary
                ),
                id: id
            )
        }
        
        return .none
        
    case .setNavigation(selection: .none):
        state.selectedSummary = nil
        return .none
    }
}

public struct HorizontalMonthlySummaryView: View {

    let store: Store<MonthlySummaryState, MonthlySummaryAction>
    @ObservedObject var viewStore: ViewStore<MonthlySummaryState, MonthlySummaryAction>
    
    public init(
        store: Store<MonthlySummaryState, MonthlySummaryAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        VStack {
            HStack {
                Text("Summary")
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(viewStore.monthlySummary) { summary in
                        
                        NavigationLink(
                            destination: IfLetStore(
                                self.store.scope(
                                    state: \.selectedSummary?.value
                                ),
                                then: { MonthlySummaryDetailView(store: $0.actionless) }
                            ),
                            tag: summary.id,
                            selection: viewStore.binding(
                                get: \.selectedSummary?.id,
                                send: MonthlySummaryAction.setNavigation(selection:)
                            )
                        ) {
                            MonthlySummaryCardView(summary: summary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

struct HorizontalSummaryView_Previews: PreviewProvider {
    
    static let list = [
        MonthlySummary(
            id: UUID(),
            dateRange: DateComponents(
                calendar: .current,
                timeZone: .current,
                year: 2020,
                month: 11
            ),
            wins: 12,
            loses: 2,
            calories: 459,
            heartRateAverage: 145,
            matches: []
        ),
        MonthlySummary(
            id: UUID(),
            dateRange: DateComponents(
                calendar: .current,
                timeZone: .current,
                year: 2021,
                month: 10
            ),
            wins: 12,
            loses: 2,
            calories: 459,
            heartRateAverage: 145,
            matches: []
        )
    ]
    
    static var previews: some View {
        NavigationView {
            HorizontalMonthlySummaryView(
                store: Store(
                    initialState: .init(
                        matches: [
                            .init(id: .init(), date: .now, playerScore: 11, opponentScore: 9, workout: nil),
                            .init(id: .init(), date: .now, playerScore: 21, opponentScore: 18, workout: nil),
                            .init(id: .init(), date: .now, playerScore: 21, opponentScore: 18, workout: nil),
                        ],
                        selectedSummary: nil
                    ),
                    reducer: monthlySummaryReducer,
                    environment: .init()
                )
            )
        }
        .preferredColorScheme(.dark)
        
    }
}

