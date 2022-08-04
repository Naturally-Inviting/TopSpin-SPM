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
    
    public var pause: (Any.Type) async -> Void
    public var resume: (Any.Type) async -> Void
    public var end: (Any.Type) async -> Void
    public var reset: (Any.Type) async -> Void
}

public extension HealthKitDep {
    static var live: Self {
        Self(
            requestAuthorization: { try await HealthKitActor.shared.requestAuthorization(sharedSamples: $0, readSamples: $1) },
            start: { await HealthKitActor.shared.start(id: $0, workoutType: $1, locationType: $2) },
            pause: { await HealthKitActor.shared.pause(id: $0) },
            resume: { await HealthKitActor.shared.resume(id: $0) },
            end: { await HealthKitActor.shared.end(id: $0) },
            reset: { await HealthKitActor.shared.reset(id: $0) }
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
                Task {
                    try await builder.endCollection(at: date)
                    try await builder.finishWorkout()
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
        
        let date = Current.date()
        delegate.session.startActivity(with: date)
        try? await delegate.builder.beginCollection(at: date)

        return stream
    }
    
    func pause(id: Any.Type) {
        let id = ObjectIdentifier(id)
        dependencies[id]?.session.pause()
    }
    
    func end(id: Any.Type) {
        let id = ObjectIdentifier(id)
        dependencies[id]?.session.end()
    }
    
    func resume(id: Any.Type) {
        let id = ObjectIdentifier(id)
        dependencies[id]?.session.resume()
    }
    
    func reset(id: Any.Type) {
        let id = ObjectIdentifier(id)
        removeDependencies(id: id)
    }
    
    private func removeDependencies(id: ObjectIdentifier) {
        self.dependencies[id] = nil
    }
}

#endif
