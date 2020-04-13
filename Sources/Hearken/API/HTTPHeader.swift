import NIOHTTP1

/// An `HTTP` header.
///
/// This is a collection of some commonly used headers
/// but any header can be created using `.custom(name: String, value: String)`.
public enum HTTPHeader {
    /// Values for the `Content-Type` `HTTP` header.
    public enum ContentType: String {
        /// `application/json` content type.
        case json = "application/json"

        /// `application/x-www-form-urlencoded` content type.
        case urlEncodedForm = "application/x-www-form-urlencoded"
    }

    /// `Content-Type` `HTTP` header.
    case contentType(ContentType)

    /// `Content-Length` `HTTP` header.
    case contentLength(Int)

    /// Custom `HTTP` header name and value.
    case custom(name: String, value: String)
}

extension HTTPHeader {
    var rawValue: (name: String, value: String) {
        switch self {
        case let .contentType(value): return ("Content-Type", value.rawValue)
        case let .contentLength(value): return ("Content-Length", "\(value)")
        case let .custom(name, value): return (name, value)
        }
    }
}

public extension HTTPHeaders {
    /// Returns a `Bool` value indicating whether the `HTTPHeaders` contain the given `HTTPHeader`.
    /// - Parameter header: The `HTTPHeader` to find.
    func contains(_ header: HTTPHeader) -> Bool {
        contains { $0.name == header.rawValue.name && $0.value == header.rawValue.value }
    }
}

extension HTTPHeaders {
    mutating func add(_ header: HTTPHeader) {
        add(name: header.rawValue.name, value: header.rawValue.value)
    }

    var logDescription: String {
        map { "\($0.name): \($0.value)" }.joined(separator: "\n")
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
    /// Creates an instance initialized with the given elements.
    ///
    /// - Parameter elements: The elements of the new instance.
    public init(arrayLiteral elements: HTTPHeader...) {
        self.init(elements.map { $0.rawValue })
    }
}
