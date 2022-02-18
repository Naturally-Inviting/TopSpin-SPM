import Models
import SwiftUI

struct HorizontalSummaryView: View {

    var historySummary: [MatchSummary]
    
    var body: some View {
        VStack {
            HStack {
                Text("Summary")
                    .padding(.horizontal)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(historySummary) { summary in
                        NavigationLink(destination: Text("")) {
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
        MatchSummary(
            id: UUID(),
            dateRange: DateComponents(
                calendar: .current,
                timeZone: .current,
                year: 2020,
                month: 11,
                day: 11,
                hour: 13,
                minute: 30,
                second: 0
            ),
            wins: 12,
            loses: 2,
            calories: 459,
            heartRateAverage: 145,
            matches: []
        ),
        MatchSummary(
            id: UUID(),
            dateRange: DateComponents(
                calendar: .current,
                timeZone: .current,
                year: 2021,
                month: 10,
                day: 11,
                hour: 13,
                minute: 30,
                second: 0
            ),
            wins: 12,
            loses: 2,
            calories: 459,
            heartRateAverage: 145,
            matches: []
        )
    ]
    
    static var previews: some View {
        Group {
            NavigationView {
                HorizontalSummaryView(historySummary: list)
            }
            .preferredColorScheme(.dark)

            NavigationView {
                HorizontalSummaryView(historySummary: list)
                    .background(Color(.secondarySystemBackground))
            }
        }
    }
}

