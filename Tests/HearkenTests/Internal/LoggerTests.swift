import XCTest
@testable import Hearken

final class LoggerTests: XCTestCase {
    func testEnabled() {
        let logger = Logger(isEnabled: true)
        logger.log(title: "Title", content: "Content")
    }

    func testDisabled() {
        let logger = Logger(isEnabled: false)
        logger.log(title: "Title", content: "Content")
    }

    func testCreateLogString() {
        let logger = Logger(isEnabled: false)
        let logString = logger.createLogString(title: "Title", content: "Content")
        XCTAssertEqual(
            logString,
            """
            ------ Title ------
            Content
            ----------------------

            """
        )
    }
}
