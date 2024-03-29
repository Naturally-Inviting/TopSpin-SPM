import Models
import SwiftUI

struct MatchSummaryWorkoutView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var workout: Workout
    
    var yellowColor: Color {
        #if os(watchOS)
        return .yellow
        #else
        return colorScheme == .dark ? .yellow : Color(UIColor.label)
        #endif
    }
  
    var largeMetricRow: some View {
        HStack {
            LargeMetricView(title: "Duration") {
                Text(workout.duration)
                    .foregroundColor(yellowColor)
            }
            
            Spacer()
            
            LargeMetricView(title: "Active Calories") {
                HStack(spacing: 0) {
                    Text("\(workout.activeCalories)")
                        .foregroundColor(.green)
                    Text("CAL")
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    var largeMetricList: some View {
        VStack(spacing: 4) {
            HStack {
                LargeMetricView(title: "Duration") {
                    Text(workout.duration)
                        .foregroundColor(yellowColor)
                }
                
                Spacer()
            }
                     
            Divider()

            HStack {
                LargeMetricView(title: "Active Calories") {
                    HStack(spacing: 0) {
                        Text("\(workout.activeCalories)")
                            .foregroundColor(.green)
                        Text("CAL")
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    var heartRateContent: some View {
        VStack(alignment: .leading) {
            Text("Heart Rate")
                .font(.headline)
            
            HeartRatesView(
                metrics: .init(
                    heartRateAverage: workout.heartRateAverage,
                    heartRateMax: workout.heartRateMax,
                    heartRateMin: workout.heartRateMin
                )
            )
        }
    }
    
    var workoutMetrics: some View {
        VStack(spacing: 4) {
            Divider()
            
            #if os(watchOS)
            largeMetricList
            #else
            largeMetricRow
            #endif
            
            Divider()

            #if os(watchOS)
            heartRateContent
            #else
            heartRateContent
                .padding()
            #endif
            
            Divider()
        }
    }
    
    var body: some View {
        workoutMetrics
    }
}

struct MatchSummaryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var match: Match
    
    var content: some View {
        ScrollView {
            MatchSummaryScoreView(
                score: "\(match.playerScore)-\(match.opponentScore)",
                didWin: match.playerScore > match.opponentScore,
                date: match.workout?.timeFrame ?? match.startTime
            )
            
            if let workout = match.workout {
                MatchSummaryWorkoutView(workout: workout)
            } else {
                Text("No Workout Data")
                    .foregroundColor(.secondary)
                    .padding(16)
            }
        }
        .navigationTitle("Sat, Sep 9")
    }
    
    var body: some View {
        #if os(watchOS)
        content
        #else
        content
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}


struct MatchSummaryView_Previews: PreviewProvider {
    static let mockMatch: Match = .init(
        id: .init(),
        date: .init(),
        playerScore: 11,
        opponentScore: 8,
        workout: .init(
            id: .init(),
            startDate: .distantPast,
            endDate: .init(),
            activeCalories: 210,
            heartRateAverage: 120,
            heartRateMax: 132,
            heartRateMin: 110
        )
    )
    
    static var previews: some View {
        Group {
            MatchSummaryView(match: mockMatch)
                .preferredColorScheme(.dark)
            
            NavigationView {
                MatchSummaryView(match: mockMatch)
            }
            
            NavigationView {
                MatchSummaryView(
                    match: .init(
                        id: .init(),
                        date: .init(),
                        playerScore: 11,
                        opponentScore: 8
                    )
                )
            }
            .preferredColorScheme(.dark)
        }
    }
}
