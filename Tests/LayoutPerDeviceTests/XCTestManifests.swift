import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LayoutPerDeviceTests.allTests),
    ]
}
#endif
