import NIOHTTP1

/// A simplified model for `HTTP` responses.
public struct HTTPResponse: Equatable {
    /// `HTTP` response status eg. `200 OK`.
    public let status: HTTPResponseStatus

    /// `HTTP` response headers eg. `Content-Type: application/json`.
    public let headers: HTTPHeaders

    /// `HTTP` response body.
    public let body: HTTPBody?

    /// Creates an instance of `HTTPResponse`.
    /// - Parameters:
    ///   - status: `HTTP` response status eg. `200 OK`.
    ///   - headers: `HTTP` response headers eg. `Content-Type: application/json`. Defaults to empty.
    ///   - body: `HTTP` response body. Defaults to `nil`.
    public init(status: HTTPResponseStatus,
                headers: HTTPHeaders = [],
                body: HTTPBody? = nil) {
        self.status = status
        self.headers = headers
        self.body = body
    }
}
