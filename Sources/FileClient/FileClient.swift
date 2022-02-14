import Combine
import ComposableArchitecture
import Foundation
import CombineHelpers

public struct FileClient {
    public var delete: (String) -> Effect<Never, Error>
    public var load: (String) -> Effect<Data, Error>
    public var save: (String, Data) -> Effect<Never, Error>
    
    public func load<A: Decodable>(
        _ type: A.Type, from fileName: String
    ) -> Effect<Result<A, NSError>, Never> {
        self.load(fileName)
            .decode(type: A.self, decoder: JSONDecoder())
            .mapError { $0 as NSError }
            .catchToEffect()
    }
    
    public func save<A: Encodable>(
        _ data: A, to fileName: String, on queue: AnySchedulerOf<DispatchQueue>
    ) -> Effect<Never, Never> {
        Just(data)
            .subscribe(on: queue)
            .encode(encoder: JSONEncoder())
            .flatMap { data in self.save(fileName, data) }
            .ignoreFailure()
            .eraseToEffect()
    }
}

public extension FileClient {
    static let noop = Self { _ in
        return .none
    } load: { _ in
        return .none
    } save: { _, _ in
        return .none
    }
    
    static let failing = Self { _ in
        return .failing("FileClient.delete")
    } load: { _ in
        return .failing("FileClient.load")
    } save: { _, _ in
        return .failing("FileClient.save")
    }
}
