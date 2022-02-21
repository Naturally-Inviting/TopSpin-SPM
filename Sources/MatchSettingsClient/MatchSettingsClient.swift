import ComposableArchitecture
import CoreDataModel
import Models
import World

public struct MatchSettingsClient {
    public struct Failure: Error, Equatable {
        public init() {}
    }
    
    public var fetch: () -> Effect<[MatchSetting], MatchSettingsClient.Failure>
    public var create: (MatchSetting) -> Effect<MatchSetting, MatchSettingsClient.Failure>
    public var delete: (MatchSetting) -> Effect<Never, Never>
    
    public init(
        fetch: @escaping () -> Effect<[MatchSetting], MatchSettingsClient.Failure>,
        create: @escaping (MatchSetting) -> Effect<MatchSetting, MatchSettingsClient.Failure>,
        delete: @escaping (MatchSetting) -> Effect<Never, Never>
    ) {
        self.fetch = fetch
        self.create = create
        self.delete = delete
    }
}

public extension MatchSettingsClient {
    static var live: Self = Self(
        fetch: {
            Current.coreDataStack().fetch(MatchSettingMO.self, predicate: nil, limit: nil)
                .publisher
                .map({ $0.map({ $0.asMatchSetting() }) })
                .mapError { _ in Failure() }
                .eraseToEffect()
        },
        create: { model in
            let managedObject = MatchSettingMO.initFrom(model)
            return Current.coreDataStack().create(managedObject)
                .publisher
                .map({ $0.asMatchSetting() })
                .mapError { _ in Failure() }
                .eraseToEffect()
        },
        delete: { model in
            guard let managedObject = try? Current.coreDataStack().fetchFirst(MatchSettingMO.self, predicate: NSPredicate(format: "id == %@", model.id.uuidString)).get() else {
                return .none
            }
            
            return .fireAndForget {
                Current.coreDataStack().delete(managedObject)
            }
        }
    )
}
