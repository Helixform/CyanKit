import XCTest
@testable import CyanKit

final class CyanKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CyanKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
