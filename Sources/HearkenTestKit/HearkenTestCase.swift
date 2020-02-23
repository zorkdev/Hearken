import XCTest
import Hearken

/// An `XCTestCase` subclass that instantiates a `Server` for each test scenario.
///
/// Create your own subclass of `HearkenTestCase` in your tests:
///
/// ```
/// import HearkenTestKit
///
/// class MyTestCase: HearkenTestCase {
///     ...
/// }
/// ```
///
/// Use the assert method to check that the tested application makes the correct request:
///
/// ```
/// func testSomething() {
///     assert(request: .init(method: .POST,
///                           uri: "/api/test",
///                           body: "Body",
///            response: .init(status: .ok))
///     ...
/// }
/// ```
///
/// - Important: Don't forget to set the domains the tested application calls to `localhost:8888`.
open class HearkenTestCase: XCTestCase {
    /// The `Server` to be used in each test scenario.
    ///
    /// The `Server` is started in `setUp()` and stopped in `tearDown()`,
    /// failing the test if something goes wrong.
    public let server = Server()

    override open func setUp() {
        super.setUp()

        do {
            try server.start()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override open func tearDown() {
        super.tearDown()

        do {
            try server.stop()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    /// Asserts that the request provided and the actually received request match.
    ///
    /// If the request has the `Content-Type: application/json` header,
    /// the body is parsed into a JSON and then matched.
    /// Similarly if it has `Content-Type: application/x-www-form-urlencoded`,
    /// the body is parsed into a `Dictionary` and then matched.
    /// Otherwise the raw `Data` is matched.
    ///
    /// Networking libraries usually add some headers to the requests
    /// even if the application did not so `headersMustMatch` defaults to `false`.
    ///
    /// - Parameters:
    ///   - request: The `HTTPRequest` to match with the received request.
    ///   - response: The `HTTPResponse` to be returned.
    ///   - headersMustMatch: Enforce the matching of the `HTTPHeaders`. Defaults to `false`.
    public func assert(request: HTTPRequest,
                       response: HTTPResponse,
                       headersMustMatch: Bool = false) {
        server[request.method, request.uri] = { actualRequest in
            XCTAssertEqual(actualRequest.method, request.method)
            XCTAssertEqual(actualRequest.uri, request.uri)

            if headersMustMatch {
                XCTAssertEqual(actualRequest.headers, request.headers)
            }

            if let body = request.body,
                let actualBody = actualRequest.body {
                if actualRequest.headers.contains(.contentType(.json)) {
                    XCTAssertEqual(self.decode(json: actualBody), self.decode(json: body))
                } else if actualRequest.headers.contains(.contentType(.urlEncodedForm)) {
                    XCTAssertEqual(self.decode(urlEncodedForm: actualBody), self.decode(urlEncodedForm: body))
                } else {
                    XCTAssertEqual(actualBody, body)
                }
            } else {
                XCTAssertEqual(actualRequest.body, request.body ?? Data())
            }

            return response
        }
    }
}

private extension HearkenTestCase {
    func decode(json body: Data) -> [String: AnyHashable] {
        do {
            let json = try JSONSerialization.jsonObject(with: body, options: [])

            guard let dictionary = json as? [String: AnyHashable] else {
                XCTFail("Request body is not a valid JSON object.")
                return [:]
            }

            return dictionary
        } catch {
            XCTFail(error.localizedDescription)
        }

        return [:]
    }

    private func decode(urlEncodedForm body: Data) -> [String: String] {
        let pairs = String(decoding: body, as: UTF8.self)
            .components(separatedBy: "&")
            .map { value -> (String, String) in
                let pair = value.components(separatedBy: "=")
                return (pair[0], pair[1])
            }

        return Dictionary(uniqueKeysWithValues: pairs)
    }
}
