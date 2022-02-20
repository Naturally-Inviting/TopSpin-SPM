import SwiftUI

struct WorkoutHeartMetric: Equatable, Codable {
    let heartRateAverage: Int
    let heartRateMax: Int
    let heartRateMin: Int
}

struct HeartRatesView: View {
    
    var metrics: WorkoutHeartMetric
    
    var content: some View {
        HStack {
            HeartRateValueView(title: "AVG", subtitle: "\(metrics.heartRateAverage)")
                .padding(.trailing)

            Divider()

            HeartRateValueView(title: "MIN", subtitle: "\(metrics.heartRateMin)")
                .padding(.horizontal)

            Divider()

            HeartRateValueView(title: "MAX", subtitle: "\(metrics.heartRateMax)")
                .padding(.horizontal)

            Spacer()
        }
    }
    
    var watchContent: some View {
            HStack(spacing: 8) {
                HeartRateValueView(title: "AVG", subtitle: "\(metrics.heartRateAverage)")
                
                HeartRateValueView(title: "MIN", subtitle: "\(metrics.heartRateMin)")
                
                HeartRateValueView(title: "MAX", subtitle: "\(metrics.heartRateMax)")
                
                Spacer()
            }
    }
    
    var body: some View {
        #if os(watchOS)
        watchContent
        #else
        content
        #endif
    }
}

struct HeartRatesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HeartRatesView(metrics: WorkoutHeartMetric(heartRateAverage: 120, heartRateMax: 123, heartRateMin: 123))
            HeartRatesView(metrics: WorkoutHeartMetric(heartRateAverage: 120, heartRateMax: 123, heartRateMin: 123))
                .colorScheme(.dark)
        }
    }
}
