import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RallyTests.allTests),
        testCase(RallyServeTests.allTests)
    ]
}
#endif
