import ComposableArchitecture
import Models
import SwiftUI
import World

public struct MonthlyDetailState: Equatable {
    public init(summary: MonthlySummary) {
        self.summary = summary
    }
    
    var summary: MonthlySummary
}

struct MonthlySummaryDetailView: View {
    let store: Store<MonthlyDetailState, Never>
    @ObservedObject var viewStore: ViewStore<MonthlyDetailState, Never>
    
    init(
        store: Store<MonthlyDetailState, Never>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
        MonthlySummaryDetail(summary: viewStore.summary)
    }
}

struct MonthlySummaryDetail: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    var summary: MonthlySummary
    
    var heartPoints: [Double] {
        return summary.matches
            .compactMap({ $0.workout?.heartRateAverage })
            .compactMap({ Double($0) })
    }
    
    var caloriePoints: [Double] {
        return summary.matches
            .compactMap({ $0.workout?.activeCalories })
            .compactMap({ Double($0) })
    }
    
    var bodyContent: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wins")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .bold()
                    
                    Text("\(summary.wins)")
                        .font(Font.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Losses")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .bold()
                    Text("\(summary.loses)")
                        .font(Font.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                }
                
                Spacer()
                Spacer()
            }
            .padding(.bottom)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .bold()
                    Text("\(summary.calories)")
                        .font(Font.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .bold()
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg. Heart Rate")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .bold()
                    Text("\(summary.heartRateAverage)")
                        .font(Font.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                }
                Spacer()
                Spacer()
            }
            .frame(maxHeight: 50)
        }
    }
    
    var body: some View {
        VStack {
            bodyContent
                .padding()
            
            MetricGraphView(
                title: "Average Heart Rate",
                labels: summary.matches.map({ $0.shortDate }),
                data: heartPoints,
                foregroundColor: ColorGradient(.pink, .red)
            )
            MetricGraphView(
                title: "Calories Burned",
                labels: summary.matches.map({ $0.shortDate }),
                data: caloriePoints,
                foregroundColor: ColorGradient(.green)
            )
            
            Spacer()
        }
        .navigationTitle(summary.dateRange(in: Current.calendar))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MonthlySummaryDetail_Previews: PreviewProvider {
    
    static let matchRange: CountableClosedRange = 1...14
    static let summary = MonthlySummary(
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
    )
    
    static var previews: some View {
        Group {
            NavigationView {
                MonthlySummaryDetail(summary: summary)
            }
            NavigationView {
                MonthlySummaryDetail(summary: summary)
            }
            .preferredColorScheme(.dark)
        }
    }
}
