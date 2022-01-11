import Foundation
import XCTestDynamicOverlay

extension UserDefaultsClient {
    public static let noop = Self(
        boolForKey: { _ in false },
        stringForKey: { _ in nil },
        dataForKey: { _ in nil },
        doubleForKey: { _ in 0 },
        integerForKey: { _ in 0 },
        remove: { _ in .none },
        setBool: { _, _ in .none },
        setValue: { _, _ in .none },
        setData: { _, _ in .none },
        setDouble: { _, _ in .none },
        setInteger: { _, _ in .none },
        clear: { .none }
    )
}

extension UserDefaultsClient {
    public static let failing = Self(
        boolForKey: { key in
            XCTFail("\(Self.self).boolForKey(\(key)) is unimplemented")
            return false
        },
        stringForKey: { key in
            XCTFail("\(Self.self).boolForKey(\(key)) is unimplemented")
            return nil
        },
        dataForKey: { key in
            XCTFail("\(Self.self).dataForKey(\(key)) is unimplemented")
            return nil
        },
        doubleForKey: { key in
            XCTFail("\(Self.self).doubleForKey(\(key)) is unimplemented")
            return 0
        },
        integerForKey: { key in
            XCTFail("\(Self.self).integerForKey(\(key)) is unimplemented")
            return 0
        },
        remove: { key in .failing("\(Self.self).remove(\(key)) is unimplemented") },
        setBool: { _, key in .failing("\(Self.self).setBool(\(key), _) is unimplemented") },
        setValue: { _, key in .failing("\(Self.self).setValue(\(key), _) is unimplemented") },
        setData: { _, key in .failing("\(Self.self).setData(\(key), _) is unimplemented") },
        setDouble: { _, key in .failing("\(Self.self).setDouble(\(key), _) is unimplemented") },
        setInteger: { _, key in .failing("\(Self.self).setInteger(\(key), _) is unimplemented") },
        clear: { .failing("\(Self.self).clear() is unimplemented") }
    )
}
