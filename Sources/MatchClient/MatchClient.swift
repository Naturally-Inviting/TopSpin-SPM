import ComposableArchitecture
import CoreDataModel
import Models
import World

public struct MatchClient {
    public struct Failure: Error, Equatable {
        public init() {}
    }
    
    public var fetch: () -> Effect<[Match], MatchClient.Failure>
    public var create: (Match) -> Effect<Match, MatchClient.Failure>
    public var delete: (Match) -> Effect<Never, Never>
    
    public init(
        fetch: @escaping () -> Effect<[Match], MatchClient.Failure>,
        create: @escaping (Match) -> Effect<Match, MatchClient.Failure>,
        delete: @escaping (Match) -> Effect<Never, Never>
    ) {
        self.fetch = fetch
        self.create = create
        self.delete = delete
    }
}

public extension MatchClient {
    static var live: Self = Self(
        fetch: {
            Current.coreDataStack().fetch(MatchMO.self, predicate: nil, limit: nil)
                .publisher
                .map({ $0.map({ $0.asMatch() }) })
                .mapError { _ in Failure() }
                .eraseToEffect()
        },
        create: { model in
            let managedObject = MatchMO.initFrom(model)
            return Current.coreDataStack().create(managedObject)
                .publisher
                .map({ $0.asMatch() })
                .mapError { _ in Failure() }
                .eraseToEffect()
        },
        delete: { model in
            guard let managedObject = try? Current.coreDataStack().fetchFirst(MatchMO.self, predicate: NSPredicate(format: "id == %@", model.id.uuidString)).get() else {
                return .none
            }
            
            return .fireAndForget {
                Current.coreDataStack().delete(managedObject)
            }
        }
    )
}
