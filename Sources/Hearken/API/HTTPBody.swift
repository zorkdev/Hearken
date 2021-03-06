import Foundation

/// The body of `HTTP` requests.
///
/// Conforms to `ExpressibleByStringLiteral` so
/// the following is also a valid way to initialize it:
/// ```
/// let body: HTTPBody = "Body content"
/// ```
public typealias HTTPBody = Data

extension HTTPBody {
    var utf8String: String { .init(decoding: self, as: UTF8.self) }
}

extension HTTPBody: ExpressibleByStringLiteral {
    /// Creates an instance initialized to the given string value.
    ///
    /// - Parameter value: The value of the new instance.
    public init(stringLiteral value: String) {
        self.init(value.utf8)
    }
}
