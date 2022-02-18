import Models
import SwiftUI
import World

struct MonthlySummaryCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    @State private var isExpanded: Bool = false
    
    var summary: MatchSummary
    
    var backgroundColor: UIColor {
        return colorScheme == .dark ? .secondarySystemBackground : .systemBackground
    }
    
    var bodyContent: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(summary.dateRange(in: Current.calendar))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .bold()
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wins")
                        .font(.caption)
                        .foregroundColor(.green)
                        .bold()
                    
                    Text("\(summary.wins)")
                        .font(Font.system(.title, design: .rounded))
                        .fontWeight(.bold)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Losses")
                        .font(.caption)
                        .foregroundColor(.red)
                        .bold()
                    Text("\(summary.loses)")
                        .font(Font.system(.title, design: .rounded))
                        .fontWeight(.bold)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .bold()
                    Text("\(summary.calories)")
                        .font(Font.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .bold()
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg. Heart Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .bold()
                    Text("\(summary.heartRateAverage)")
                        .font(Font.system(.title, design: .rounded))
                        .fontWeight(.bold)
                }
                
                if horizontalSize != .regular {
                    Spacer()
                }
            }
            .frame(maxHeight: 50)
        }
    }
    
    var body: some View {
        bodyContent
            .minimumScaleFactor(0.7)
            .lineLimit(1)
            .layoutPriority(1)
            .padding()
            .padding(.trailing)
            .background(Color(backgroundColor))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.05), radius: 8, x: 0, y: 4)
    }
}

struct HistorySummaryView_Previews: PreviewProvider {
    
    static let summary = MatchSummary(
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
    )
    
    static var previews: some View {
        Group {
            MonthlySummaryCardView(summary: summary)
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .padding()
            
            MonthlySummaryCardView(summary: summary)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
