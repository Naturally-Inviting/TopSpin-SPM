#if canImport(HealthKit)
import Combine
import ComposableArchitecture
import HealthKit
import World

public struct HealthKitClient {
    public var requestAuthorization: (AnyHashable, Set<HKSampleType>?, Set<HKObjectType>?) -> Effect<Action, Never>
    public var start: (AnyHashable, HKWorkoutActivityType, HKWorkoutSessionLocationType) -> Effect<Action, Failure>
    public var pause: (AnyHashable) -> Effect<Never, Never>
    
//    public var end: () -> Effect<Never, Never>
    public var resume: (AnyHashable) -> Effect<Never, Never>
    public var end: (AnyHashable) -> Effect<Never, Never>
    public var reset: (AnyHashable) -> Effect<Never, Never>

    
    public enum Action {
        case authorizationDidChange(isAuthorized: Bool)
        case workoutSessionDidChange(HKWorkoutSessionState, HKWorkoutSessionState)
        case didCollectData(HKLiveWorkoutBuilder, Set<HKSampleType>)
        case builderDidCollectEvent(HKLiveWorkoutBuilder)
    }
    
    public enum Failure: Equatable, Error {
        case failed
        case workoutSessionDidFail
    }
}

private var dependencies: [AnyHashable: HealthKitDelegate] = [:]

private class HealthKitDelegate: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    
    let workoutSessionDidChange: (HKWorkoutSessionState, HKWorkoutSessionState) -> Void
    let sessionDidFail: () -> Void
    let didCollectData: (HKLiveWorkoutBuilder, Set<HKSampleType>) -> Void
    let workoutBuilderDidCollectEvent: (HKLiveWorkoutBuilder) -> Void
    
    init(
        configuration: HKWorkoutConfiguration,
        workoutSessionDidChange:  @escaping (HKWorkoutSessionState, HKWorkoutSessionState) -> Void,
        sessionDidFail:  @escaping () -> Void,
        didCollectData:  @escaping (HKLiveWorkoutBuilder, Set<HKSampleType>) -> Void,
        workoutBuilderDidCollectEvent:  @escaping (HKLiveWorkoutBuilder) -> Void
    ) {
        self.workoutSessionDidChange = workoutSessionDidChange
        self.sessionDidFail = sessionDidFail
        self.didCollectData = didCollectData
        self.workoutBuilderDidCollectEvent = workoutBuilderDidCollectEvent
        
        super.init()
        
        session = try? HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session.associatedWorkoutBuilder()

        session.delegate = self
        builder.delegate = self
        
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: configuration)
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        self.workoutSessionDidChange(toState, fromState)
        
        if toState == .ended {
            builder.endCollection(withEnd: date) { success, error in
                self.builder.finishWorkout { workout, error in
                    // TODO: Anything to do here?
                    print(error as Any)
                }
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        self.sessionDidFail()
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        guard session.state == .running else { return }
        self.didCollectData(workoutBuilder, collectedTypes)
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        self.workoutBuilderDidCollectEvent(workoutBuilder)
    }
}

extension HealthKitClient {
    public static var live: Self {
        Self(
            requestAuthorization: { id, share, read in
                .future { callback in
                    HKHealthStore().requestAuthorization(toShare: share, read: read) { isAuthorized, error in
                        if error != nil {
                            callback(.success(.authorizationDidChange(isAuthorized: false)))
                        } else {
                            callback(.success(.authorizationDidChange(isAuthorized: isAuthorized)))
                        }
                    }
                }
            },
            start: { id, workoutType, locationType in
                Effect.run { subscriber in
                    let configuration = HKWorkoutConfiguration()
                    configuration.activityType = workoutType
                    configuration.locationType = locationType
                    
                    let delegate = HealthKitDelegate(
                        configuration: configuration,
                        workoutSessionDidChange: { toState, fromState in
                            subscriber.send(.workoutSessionDidChange(toState, fromState))
                        },
                        sessionDidFail: {
                            subscriber.send(completion: .failure(.workoutSessionDidFail))
                        },
                        didCollectData: { builder, samples in
                            subscriber.send(.didCollectData(builder, samples))
                        },
                        workoutBuilderDidCollectEvent: { builder in
                            subscriber.send(.builderDidCollectEvent(builder))
                        }
                    )
                    
                    dependencies[id] = delegate
                    let date = Current.date()
                    delegate.session.startActivity(with: date)
                    delegate.builder.beginCollection(withStart: date) { didSucced, error in
                        // TODO: See if this closure is needed.
                        print(error as Any)
                    }
                    
                    return AnyCancellable {
                        dependencies[id] = nil
                    }
                }
            }, pause: { id in
                .fireAndForget {
                    dependencies[id]?.session.pause()
                }
            }, resume: { id in
                .fireAndForget {
                    dependencies[id]?.session.resume()
                }
            }, end: { id in
                .fireAndForget {
                    dependencies[id]?.session.end()
                }
            }, reset: { id in
                .fireAndForget {
                    dependencies[id] = nil
                }
            }
        )
    }
}

#endif
