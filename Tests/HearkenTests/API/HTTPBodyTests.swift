import XCTest
@testable import Hearken

final class HTTPBodyTests: XCTestCase {
    func testUTF8String() {
        let body = "Body".data(using: .utf8)
        XCTAssertEqual(body?.utf8String, "Body")
    }

    func testExpressibleByStringLiteral() {
        let expectedBody = "Body".data(using: .utf8)
        let body: HTTPBody = "Body"
        XCTAssertEqual(body, expectedBody)
    }
}
