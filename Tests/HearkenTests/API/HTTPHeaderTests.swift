import XCTest
import NIOHTTP1
@testable import Hearken

final class HTTPHeaderTests: XCTestCase {
    func testRawValue() {
        XCTAssertEqual(HTTPHeader.contentType(.json).rawValue.name, "Content-Type")
        XCTAssertEqual(HTTPHeader.contentType(.json).rawValue.value, "application/json")

        XCTAssertEqual(HTTPHeader.contentType(.urlEncodedForm).rawValue.name, "Content-Type")
        XCTAssertEqual(HTTPHeader.contentType(.urlEncodedForm).rawValue.value, "application/x-www-form-urlencoded")

        XCTAssertEqual(HTTPHeader.contentLength(2).rawValue.name, "Content-Length")
        XCTAssertEqual(HTTPHeader.contentLength(2).rawValue.value, "2")

        XCTAssertEqual(HTTPHeader.custom(name: "Name", value: "value").rawValue.name, "Name")
        XCTAssertEqual(HTTPHeader.custom(name: "Name", value: "value").rawValue.value, "value")
    }

    func testContains() {
        let headers: HTTPHeaders = [.contentType(.json), .contentLength(2)]
        XCTAssertTrue(headers.contains(.contentType(.json)))
        XCTAssertFalse(headers.contains(.contentType(.urlEncodedForm)))
    }

    func testAdd() {
        var headers = HTTPHeaders()
        headers.add(.contentType(.json))
        XCTAssertEqual(headers, [.contentType(.json)])
    }

    func testLogDescription() {
        let headers: HTTPHeaders = [.contentType(.json), .contentLength(2)]
        XCTAssertEqual(
            headers.logDescription,
            """
            Content-Type: application/json
            Content-Length: 2
            """
        )
    }

    func testExpressibleByArrayLiteral() {
        let headers: HTTPHeaders = [.contentType(.json)]
        let expectedHeaders = HTTPHeaders([("Content-Type", "application/json")])
        XCTAssertEqual(headers, expectedHeaders)
    }
}
