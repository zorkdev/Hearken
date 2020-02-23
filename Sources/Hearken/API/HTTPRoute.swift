import NIOHTTP1

extension HTTPMethod: Hashable {}

/// A model for `HTTP` routes.
public struct HTTPRoute: Hashable {
    /// `HTTP` method eg. `POST`.
    public let method: HTTPMethod

    /// `HTTP` `URI` eg. `/api/test`.
    public let uri: String

    /// Creates an instance of `HTTPRoute`.
    /// - Parameters:
    ///   - method: `HTTP` method eg. `POST`.
    ///   - uri: `HTTP` `URI` eg. `/api/test`.
    public init(method: HTTPMethod, uri: String) {
        self.method = method
        self.uri = uri
    }
}
