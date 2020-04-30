import XCTest
@testable import Tunisia

final class TunisiaTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Tunisia().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
