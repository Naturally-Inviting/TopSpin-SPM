import SwiftUI

struct HistoryWorkoutMetricView: View {
    
    var metricContent: WorkoutStatsViewContent
    
    var body: some View {
        HStack(spacing: 0) {
            HorizontalIconView(
                image: Image(systemName:"clock"),
                tint: .yellow,
                title: "Duration",
                value: "\(metricContent.duration)",
                unit: "MIN"
            )
            
            Spacer()
            
            HorizontalIconView(
                image: Image(systemName:"waveform.path.ecg"),
                tint: .green,
                title: "Calories",
                value: "\(metricContent.calories)",
                unit: "CAL"
            )
            
            Spacer()
            
            HorizontalIconView(
                image: Image(systemName:"heart"),
                tint: .red,
                title: "Avg. Pulse",
                value: "\(metricContent.heartRateAverage)",
                unit: "BPM"
            )
        }
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .layoutPriority(1)
    }
}

struct HistoryWorkoutMetricView_Previews: PreviewProvider {
    
    static func content() -> WorkoutStatsViewContent {
        let matchStartString = "2020-09-20T14:13:00+0000"
        let matchEndString = "2020-09-20T14:43:00+0000"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return WorkoutStatsViewContent(
            startDate: dateFormatter.date(from: matchStartString)!,
            endDate: dateFormatter.date(from: matchEndString)!,
            calories: 320,
            heartRateAverage: 132,
            heartRateMax: 143,
            heartRateMin: 123
        )
    }
    
    static var previews: some View {
        Group {
            HistoryWorkoutMetricView(metricContent: content())
                .previewLayout(.sizeThatFits)
                .padding()
            
            HistoryWorkoutMetricView(metricContent: content())
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
