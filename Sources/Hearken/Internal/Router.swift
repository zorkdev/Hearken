final class Router {
    var routes: [HTTPRoute: (HTTPRequest) -> HTTPResponse] = [:]

    func route(request: HTTPRequest) -> HTTPResponse? {
        routes.first { $0.key == request.route }
            .map { $0.value(request) }
    }
}
