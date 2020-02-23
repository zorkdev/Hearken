import NIOHTTP1

/// A simplified model for `HTTP` requests.
public struct HTTPRequest: Equatable {
    /// `HTTP` request method eg. `POST`.
    public let method: HTTPMethod

    /// `HTTP` request `URI` eg. `/api/test`.
    public let uri: String

    /// `HTTP` request headers eg. `Content-Type: application/json`.
    public let headers: HTTPHeaders

    /// `HTTP` request body.
    public let body: HTTPBody?

    /// Creates an instance of `HTTPRequest`.
    /// - Parameters:
    ///   - method: `HTTP` request method eg. `POST`.
    ///   - uri: `HTTP` request `URI` eg. `/api/test`.
    ///   - headers: `HTTP` request headers eg. `Content-Type: application/json`. Defaults to empty.
    ///   - body: `HTTP` request body. Defaults to `nil`.
    public init(method: HTTPMethod,
                uri: String,
                headers: HTTPHeaders = [],
                body: HTTPBody? = nil) {
        self.method = method
        self.uri = uri
        self.headers = headers
        self.body = body
    }
}

extension HTTPRequest {
    var route: HTTPRoute { .init(method: method, uri: uri) }
}
