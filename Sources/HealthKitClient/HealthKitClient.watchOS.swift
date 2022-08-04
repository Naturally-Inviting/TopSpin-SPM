#if os(watchOS)
import HealthKit
import ComposableArchitecture
import World

public struct HealthKitDep {
    public enum Action {
        case authorizationDidChange(isAuthorized: Bool)
        case workoutSessionDidChange(HKWorkoutSessionState, HKWorkoutSessionState)
        case didCollectData(HKLiveWorkoutBuilder, Set<HKSampleType>)
        case builderDidCollectEvent(HKLiveWorkoutBuilder)
        case sessionDidFail(Error)
    }
    
    public var requestAuthorization: @Sendable (Set<HKSampleType>, Set<HKObjectType>) async throws -> Void
    public var start: @Sendable (Any.Type, HKWorkoutActivityType, HKWorkoutSessionLocationType) async -> AsyncStream<Action>
}

public extension HealthKitDep {
    static var live: Self {
        Self(
            requestAuthorization: { try await HealthKitActor.shared.requestAuthorization(sharedSamples: $0, readSamples: $1) },
            start: { await HealthKitActor.shared.start(id: $0, workoutType: $1, locationType: $2) }
        )
    }
}

final actor HealthKitActor: GlobalActor {
    final class Delegate: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
        let healthStore = HKHealthStore()
        var session: HKWorkoutSession!
        var builder: HKLiveWorkoutBuilder!
        
        var continuation: AsyncStream<HealthKitDep.Action>.Continuation?
        
        init(
            configuration: HKWorkoutConfiguration
        ) {
            super.init()
            
            session = try? HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session.associatedWorkoutBuilder()

            session.delegate = self
            builder.delegate = self
            
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                         workoutConfiguration: configuration)
        }
        
        func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
            self.continuation?.yield(.workoutSessionDidChange(toState, fromState))
            
            if toState == .ended {
                builder.endCollection(withEnd: date) { success, error in
                    self.builder.finishWorkout { workout, error in
                        self.continuation?.finish() // Need this here?
                    }
                }
            }
        }
        
        func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
            self.continuation?.yield(.sessionDidFail(error))
        }
        
        func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
            guard session.state == .running else { return }
            self.continuation?.yield(.didCollectData(workoutBuilder, collectedTypes))
        }
        
        func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
            self.continuation?.yield(.builderDidCollectEvent(workoutBuilder))
        }
        
    }
    
    static let shared = HealthKitActor()
    var dependencies: [ObjectIdentifier: Delegate] = [:]

    func requestAuthorization(sharedSamples: Set<HKSampleType>, readSamples: Set<HKObjectType>) async throws {
        try await HKHealthStore().requestAuthorization(toShare: sharedSamples, read: readSamples)
        
        let status = try await HKHealthStore().statusForAuthorizationRequest(toShare: sharedSamples, read: readSamples)
        
        guard status == .unnecessary else {
            struct AuthError: Error {}
            throw AuthError()
        }
    }
    
    func start(id: Any.Type, workoutType: HKWorkoutActivityType, locationType: HKWorkoutSessionLocationType) async -> AsyncStream<HealthKitDep.Action> {
        let id = ObjectIdentifier(id)
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = locationType
        let delegate = Delegate(configuration: configuration)
        var continuation: AsyncStream<HealthKitDep.Action>.Continuation!
        
        let stream = AsyncStream<HealthKitDep.Action> {
            $0.onTermination = { _ in
                delegate.session.end()
                Task { await self.removeDependencies(id: id) }
            }
            continuation = $0
        }
        
        delegate.continuation = continuation
        dependencies[id] = delegate
        return stream
    }
    
    private func removeDependencies(id: ObjectIdentifier) {
        self.dependencies[id] = nil
    }
}



#endif
