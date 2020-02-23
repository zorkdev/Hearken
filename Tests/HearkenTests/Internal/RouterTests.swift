import XCTest
@testable import Hearken

final class RouterTests: XCTestCase {
    func testRoute() throws {
        let router = Router()
        let expectedRequest = HTTPRequest(method: .POST,
                                          uri: "/api/test",
                                          headers: [],
                                          body: nil)
        let expectedResponse = HTTPResponse(status: .ok,
                                            headers: [.contentType(.json)],
                                            body: Data([3, 4]))

        router.routes[.init(method: .POST, uri: "/api/test")] = { request in
            XCTAssertEqual(request, expectedRequest)
            return expectedResponse
        }

        let response = router.route(request: expectedRequest)
        XCTAssertEqual(response, expectedResponse)
    }
}
