import ComposableArchitecture
import HealthKit
import HealthKitClient
import SwiftUI
import World

public typealias WorkoutReducer = Reducer<WorkoutState, WorkoutAction, WorkoutEnvironment>

public struct WorkoutState: Equatable {
    public init(
        activeCalories: Int = 0,
        elapsedSeconds: Int = 0,
        heartRate: Int = 0,
        heartRateAverage: Int = 0,
        heartRateMax: Int = 0,
        heartRateMin: Int = 0,
        viewInitialized: Bool = false
    ) {
        self.activeCalories = activeCalories
        self.elapsedSeconds = elapsedSeconds
        self.heartRate = heartRate
        self.heartRateAverage = heartRateAverage
        self.heartRateMax = heartRateMax
        self.heartRateMin = heartRateMin
        self.viewInitialized = viewInitialized
    }
    
    var workoutState: HKWorkoutSessionState = .notStarted
    var activeCalories: Int
    var heartRate: Int
    var heartRateAverage: Int
    var heartRateMax: Int
    var heartRateMin: Int
    var viewInitialized: Bool
    
    // Timer
    var isTimerActive = false
    var elapsedSeconds = 0
    
    var foramttedSecondsString: String {
        let elapsed: (h: Int, m: Int, s: Int) = (elapsedSeconds / 3600, (elapsedSeconds % 3600) / 60, (elapsedSeconds % 3600) % 60)
        return String(format: "%d:%02d:%02d", elapsed.h, elapsed.m, elapsed.s)
    }
}

public enum WorkoutAction {
    case viewDidAppear
    case onDisappear
    
    case start
    case reset
    case resume
    case pause
    
    case cancelWorkout
    case healthKitAuth(didAuthorize: Bool)
    case healthKit(HealthKitDep.Action)
    case requestHealthAuth

    // Timer
    case timerTicked
}

public struct WorkoutEnvironment {
    public init(
        healthKitDep: HealthKitDep = .live,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.healthKitDep = healthKitDep
        self.mainQueue = mainQueue
    }
    
    var healthKitDep: HealthKitDep = .live
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

public let workoutReducer = WorkoutReducer
{ state, action, environment in
    enum HealthKitId {}
    enum TimerId {}
    
    switch action {
    case .start:
        return .run { send in
            let actions = await environment.healthKitDep.start(HealthKitId.self, .tableTennis, .indoor)
            
            await withThrowingTaskGroup(of: Void.self) { group in
                for await action in actions {
                    await send(.healthKit(action))
                }
            }
        }
        .cancellable(id: HealthKitId.self)

    case .resume:
        return .fireAndForget {
            await environment.healthKitDep.resume(HealthKitId.self)
        }
        
    case .pause:
        return .fireAndForget {
            await environment.healthKitDep.pause(HealthKitId.self)
        }
        
    case .reset:
        state.heartRate = 0
        state.heartRateAverage = 0
        state.heartRateMax = 0
        state.heartRateMin = 0
        state.activeCalories = 0
        state.elapsedSeconds = 0
        
        return Effect(value: .cancelWorkout).eraseToEffect()
        
    case .cancelWorkout:
        state.workoutState = .notStarted
        
        return .merge(
            .fireAndForget {
                await environment.healthKitDep.reset(HealthKitId.self)
            },
            .cancel(id: HealthKitId.self),
            .cancel(id: TimerId.self)
        )
        
    case .timerTicked:
        state.elapsedSeconds += 1
        return .none
        
    case let .healthKit(.didCollectData(workoutBuilder, samples)):
        for type in samples {
            guard let quantityType = type as? HKQuantityType else { return .none }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            guard let statistics = statistics else { return .none }
            
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                
                let mostRctValue = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                let avgValue = statistics.averageQuantity()?.doubleValue(for: heartRateUnit)
                
                let maxValue = statistics.maximumQuantity()?.doubleValue(for: heartRateUnit)
                let minValue = statistics.minimumQuantity()?.doubleValue(for: heartRateUnit)
                
                let roundedValue = Double( round( 1 * mostRctValue! ) / 1 )
                let roundedAvg = Int(Double( round( 1 * avgValue! ) / 1 ))
                let roundedMin = Int(Double( round( 1 * minValue! ) / 1 ))
                let roundedMax = Int(Double( round( 1 * maxValue! ) / 1 ))
                
                state.heartRate = Int(roundedValue)
                state.heartRateAverage = roundedAvg
                state.heartRateMax = roundedMax
                state.heartRateMin = roundedMin
                
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                let value = statistics.sumQuantity()?.doubleValue(for: energyUnit)
                state.activeCalories = Int(Double( round( 1 * value! ) / 1 ))
                
            default:
                return .none
            }
        }
        
        return .none
        
    case let .healthKit(.workoutSessionDidChange(toState, fromState)):
        state.workoutState = toState
        
        return .run { [workoutState = state.workoutState] send in
            guard workoutState == .running else { return }
            for await _ in  environment.mainQueue.timer(interval: .seconds(1)) {
                await send(.timerTicked)
            }
        }
        .cancellable(id: TimerId.self, cancelInFlight: true)
        
    case let .healthKitAuth(didAuthorize: isAuthorized):
        guard isAuthorized else { return .none }
        return Effect(value: .start)
        
    case .requestHealthAuth:
        return .task {
            try await environment.healthKitDep.requestAuthorization(
                [HKQuantityType.workoutType()],
                [
                    HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                    HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                ]
            )

            return .healthKitAuth(didAuthorize: true)
        } catch: { _ in
            return .healthKitAuth(didAuthorize: false)
        }
        .cancellable(id: HealthKitId.self)
        
    case .onDisappear:
        return .cancel(id: HealthKitId.self)
        
    default:
        return .none
    }
}

public struct WorkoutView: View {
    let store: Store<WorkoutState, WorkoutAction>
    @ObservedObject var viewStore: ViewStore<WorkoutState, WorkoutAction>
    
    public init(
        store: Store<WorkoutState, WorkoutAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        VStack {
            MatchWorkoutView(
                activeCalories: viewStore.activeCalories,
                elapsedSecondsString: viewStore.foramttedSecondsString,
                heartRate: viewStore.heartRate,
                heartRateAverage: viewStore.heartRateAverage,
                heartRateMax: viewStore.heartRateMax,
                heartRateMin: viewStore.heartRateMin,
                pauseLabel: viewStore.workoutState == .paused ? "Resume" : "Pause",
                pauseAction: {
                    if viewStore.workoutState == .paused {
                        viewStore.send(.resume)
                    } else {
                        viewStore.send(.pause)
                    }
                },
                cancelAction: {
                    viewStore.send(.cancelWorkout)
                }
            )
        }
        .task {
            viewStore.send(.requestHealthAuth)
        }
    }
}

struct MatchWorkoutView: View {
    var activeCalories: Int
    var elapsedSecondsString: String
    var heartRate: Int
    var heartRateAverage: Int
    var heartRateMax: Int
    var heartRateMin: Int
    var pauseLabel: String
    var pauseAction: () -> Void
    var cancelAction: () -> Void
    
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(elapsedSecondsString)
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    HStack {
                        Text("\(activeCalories)")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("ACTIVE")
                            Text("CAL")
                        }
                        .font(Font.system(size: 11))
                        .foregroundColor(.secondary)
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(heartRate)")
                            .font(.title2)
                        Text("BPM")
                            .font(Font.system(.title2).smallCaps())
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                            .padding(.leading)
                            .opacity(0.7)
                    }
                    
                    HStack {
                        
                        VStack {
                            Text("AVG")
                            Text("\(heartRateAverage)")
                        }
                        
                        Spacer()
                        Divider()
                        Spacer()
                        
                        VStack {
                            Text("MIN")
                            Text("\(heartRateMin)")
                        }
                        
                        Spacer()
                        Divider()
                        Spacer()
                        
                        VStack {
                            Text("MAX")
                            Text("\(heartRateMax)")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
                    
                    Button(pauseLabel, action: pauseAction)
                        .padding(.top)
                    
                    Button("Cancel", action: cancelAction)
                        .buttonStyle(BorderedButtonStyle(tint: .red))
                        .padding(.top)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Workout")
    }
}

struct MatchWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        MatchWorkoutView(
            activeCalories: 123,
            elapsedSecondsString: "00:12:31",
            heartRate: 133,
            heartRateAverage: 120,
            heartRateMax: 140,
            heartRateMin: 100,
            pauseLabel: "Pause",
            pauseAction: { },
            cancelAction: { }
        )
    }
}
