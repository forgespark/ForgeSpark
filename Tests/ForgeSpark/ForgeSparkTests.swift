import XCTest
@testable import ForgeSpark

class ForgeSparkTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(ForgeSpark().text, "Hello, World!")
    }


    static var allTests : [(String, (ForgeSparkTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
