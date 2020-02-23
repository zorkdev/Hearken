#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
@testable import Hearken

final class ServerTests: XCTestCase {
    func testRouteWithHandler() throws {
        let newExpectation = expectation(description: "Expectation")

        let server = Server(isLoggingEnabled: true)

        server[.POST, "/api/test"] = { request in
            XCTAssertEqual(request.method, .POST)
            XCTAssertEqual(request.uri, "/api/test")

            return .init(status: .ok,
                         headers: [.contentType(.json)],
                         body: "Response")
        }

        let handler: ((HTTPRequest) -> HTTPResponse)? = server[.POST, "/api/test"]
        let response: HTTPResponse? = server[.POST, "/api/test"]

        XCTAssertNotNil(handler)
        XCTAssertNil(response)

        try server.start()

        var request = URLRequest(url: URL(string: "http://localhost:8888/api/test")!)
        request.httpMethod = "POST"
        request.httpBody = .init("Request".utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            XCTAssertEqual(String(decoding: data ?? Data(), as: UTF8.self), "Response")
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            XCTAssertEqual((response as? HTTPURLResponse)?.allHeaderFields as? [String: String],
                           ["Content-Length": "8",
                            "Content-Type": "application/json"])
            XCTAssertNil(error)

            do {
                try server.stop()
            } catch {
                XCTFail(error.localizedDescription)
            }

            newExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testRouteWithoutHandler() throws {
        let newExpectation = expectation(description: "Expectation")

        let server = Server()

        try server.start()

        var request = URLRequest(url: URL(string: "http://localhost:8888/api/test")!)
        request.httpMethod = "POST"
        request.httpBody = .init("Request".utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            XCTAssertEqual(data, Data())
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 404)
            XCTAssertEqual((response as? HTTPURLResponse)?.allHeaderFields as? [String: String],
                           ["Content-Length": "0"])
            XCTAssertNil(error)

            do {
                try server.stop()
            } catch {
                XCTFail(error.localizedDescription)
            }

            newExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testMultipartRequest() throws {
        let newExpectation = expectation(description: "Expectation")

        let server = Server(isLoggingEnabled: true)

        server[.POST, "/api/test"] = .init(status: .ok)

        try server.start()

        var request = URLRequest(url: URL(string: "http://localhost:8888/api/test")!)
        request.httpMethod = "POST"
        request.httpBody = Data(repeating: 1, count: 3073)

        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)

            do {
                try server.stop()
            } catch {
                XCTFail(error.localizedDescription)
            }

            newExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testSyncStart() throws {
        let server = Server()

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            do {
                try server.stop()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }

        try server.syncStart()
    }

    func testLogging() throws {
        let logger = MockLogger()
        let newExpectation = expectation(description: "Expectation")

        let server = Server(port: 8888, logger: logger)

        server[.POST, "/api/test"] = .init(status: .ok,
                                           headers: [.contentType(.json)],
                                           body: "Response")

        try server.start()

        var request = URLRequest(url: URL(string: "http://localhost:8888/api/test")!)
        request.httpMethod = "POST"
        request.httpBody = .init("Request".utf8)

        let expectedStartupString =
            """
            Hearken
            Server running on localhost:8888
            """

        let expectedResponseString =
            """
            Response
            HTTP/1.1 200
            Content-Type: application/json
            Content-Length: 8

            Response
            """

        let expectedShutdownString =
            """
            Hearken
            Server was shut down gracefully
            """

        let task = URLSession.shared.dataTask(with: request) { _, _, _ in
            do {
                try server.stop()
            } catch {
                XCTFail(error.localizedDescription)
            }

            XCTAssertTrue(logger.logParams.contains(expectedStartupString))
            XCTAssertTrue(logger.logParams.contains(expectedResponseString))
            XCTAssertTrue(logger.logParams.contains(expectedShutdownString))

            newExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFalseStartStop() throws {
        let server = Server()

        try server.start()
        try server.start()
        try server.stop()
        try server.stop()
    }
}
