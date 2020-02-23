import XCTest
@testable import Hearken

final class HTTPRequestTests: XCTestCase {
    func testRoute() {
        let request = HTTPRequest(method: .POST,
                                  uri: "/api/test",
                                  headers: [],
                                  body: nil)

        let expectedRoute = HTTPRoute(method: .POST, uri: "/api/test")

        XCTAssertEqual(request.route, expectedRoute)
    }
}
