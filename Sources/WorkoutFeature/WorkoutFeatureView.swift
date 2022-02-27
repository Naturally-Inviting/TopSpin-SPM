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
        viewInitialized: Bool = false,
        isAuthorized: Bool = false
    ) {
        self.activeCalories = activeCalories
        self.elapsedSeconds = elapsedSeconds
        self.heartRate = heartRate
        self.heartRateAverage = heartRateAverage
        self.heartRateMax = heartRateMax
        self.heartRateMin = heartRateMin
        self.viewInitialized = viewInitialized
        self.isAuthorized = isAuthorized
    }
    
    var workoutState: HKWorkoutSessionState = .notStarted
    var activeCalories: Int
    var heartRate: Int
    var heartRateAverage: Int
    var heartRateMax: Int
    var heartRateMin: Int
    var viewInitialized: Bool
    var isAuthorized: Bool
    
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
    case healthKitAuth(Result<HealthKitClient.Action, Never>)
    case healthKit(Result<HealthKitClient.Action, HealthKitClient.Failure>)
    
    // Timer
    case timerTicked
}

public struct WorkoutEnvironment {
    public init(
        healthKitClient: HealthKitClient = .live,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.healthKitClient = healthKitClient
        self.mainQueue = mainQueue
    }
    
    var healthKitClient: HealthKitClient = .live
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

public let workoutReducer = WorkoutReducer
{ state, action, environment in
    struct WorkoutId: Hashable {}
    struct WorkoutCancellation: Hashable {}
    struct TimerId: Hashable {}

    switch action {
    case .start:
        return environment.healthKitClient.start(WorkoutId(), .tableTennis, .indoor)
            .receive(on: environment.mainQueue)
            .catchToEffect(WorkoutAction.healthKit)
            .cancellable(id: WorkoutCancellation())
        
    case .resume:
        return environment.healthKitClient.resume(WorkoutId())
            .fireAndForget()
        
    case .pause:
        return environment.healthKitClient.pause(WorkoutId())
            .fireAndForget()
        
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
            environment.healthKitClient.reset(WorkoutId())
                .fireAndForget(),
            .cancel(id: WorkoutCancellation()),
            .cancel(id: TimerId())
        )
        
    case .timerTicked:
        state.elapsedSeconds += 1
        return .none
        
    case let .healthKit(.success(.didCollectData(workoutBuilder, samples))):
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
        
    case let .healthKit(.success(.workoutSessionDidChange(toState, fromState))):
        state.workoutState = toState
        
        return state.workoutState == .running
          ? Effect.timer(
            id: TimerId(),
            every: 1,
            tolerance: .zero,
            on: environment.mainQueue.animation(.interpolatingSpring(stiffness: 3000, damping: 40))
          )
          .map { _ in WorkoutAction.timerTicked }
          : Effect.cancel(id: TimerId())
        
    case let .healthKitAuth(.success(.authorizationDidChange(isAuthorized))):
        state.isAuthorized = isAuthorized
        return .none
        
    case .viewDidAppear:
        if !state.viewInitialized {
            return environment.healthKitClient.requestAuthorization(
                WorkoutId(),
                [HKQuantityType.workoutType()],
                [
                    HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                    HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                ]
            )
            .receive(on: environment.mainQueue)
            .catchToEffect(WorkoutAction.healthKitAuth)
        }
        
        state.viewInitialized = true
        
        return .none
        
    case .onDisappear:
        return .cancel(id: WorkoutCancellation())
        
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
        .onAppear {
            viewStore.send(.viewDidAppear)
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
