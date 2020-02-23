#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import Hearken
import HearkenTestKit

final class HearkenTestCaseTests: HearkenTestCase {
    func testAssertJSON() {
        let newExpectation = expectation(description: "Expectation")

        let body =
            """
            {
                "hello": "world"
            }
            """

        assert(request: .init(method: .POST,
                              uri: "/api/test",
                              body: .init(body.utf8)),
               response: .init(status: .ok),
               headersMustMatch: false)

        var request = URLRequest(url: URL(string: "http://localhost:8888/api/test")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = .init(body.utf8)

        let task = URLSession.shared.dataTask(with: request) { _, _, _ in
            newExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAssertURLEncodedForm() {
        let newExpectation = expectation(description: "Expectation")

        let body = "hello=world"

        assert(request: .init(method: .POST,
                              uri: "/api/test",
                              body: .init(body.utf8)),
               response: .init(status: .ok),
               headersMustMatch: false)

        var request = URLRequest(url: URL(string: "http://localhost:8888/api/test")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = .init(body.utf8)

        let task = URLSession.shared.dataTask(with: request) { _, _, _ in
            newExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAssertPlainText() {
        let newExpectation = expectation(description: "Expectation")

        let body = "Body"

        assert(request: .init(method: .POST,
                              uri: "/api/test",
                              body: .init(body.utf8)),
               response: .init(status: .ok),
               headersMustMatch: false)

        var request = URLRequest(url: URL(string: "http://localhost:8888/api/test")!)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = .init(body.utf8)

        let task = URLSession.shared.dataTask(with: request) { _, _, _ in
            newExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAssertEmptyBody() {
        let newExpectation = expectation(description: "Expectation")

        assert(request: .init(method: .POST,
                              uri: "/api/test"),
               response: .init(status: .ok),
               headersMustMatch: false)

        var request = URLRequest(url: URL(string: "http://localhost:8888/api/test")!)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { _, _, _ in
            newExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2, handler: nil)
    }
}
