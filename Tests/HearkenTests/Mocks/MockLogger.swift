@testable import Hearken

final class MockLogger: LoggerType {
    var logParams: [String] = []
    func log(title: String, content: String) {
        logParams.append("\(title)\n\(content)")
    }
}
