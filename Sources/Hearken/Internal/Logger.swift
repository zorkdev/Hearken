protocol LoggerType {
    func log(title: String, content: String)
}

final class Logger: LoggerType {
    private let isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func log(title: String, content: String) {
        guard isEnabled else { return }
        print(createLogString(title: title, content: content))
    }

    func createLogString(title: String, content: String) -> String {
        """
        ------ \(title) ------
        \(content)
        ----------------------

        """
    }
}
