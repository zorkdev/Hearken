import NIO
import NIOHTTP1

/// An `HTTP` server.
///
/// An instance of `Hearken` can be easily created by initializing a `Server`:
///
/// ```
/// import Hearken
///
/// let server = Server()
/// ```
///
/// Simple routes with a response instance can be added
/// by using a custom subscript on `Server`:
///
/// ```
/// server[.GET, "/api/health"] = HTTPResponse(status: .ok)
/// ```
///
/// You can also assign closures to routes by using another
/// custom subscript on `Server` if you need more control over your route:
///
/// ```
/// server[.POST, "/api/hello"] = { request in
///     print(request)
///
///     return .init(status: .ok,
///                  headers: [.contentType(.json)],
///                  body: """
///                        {
///                            "hello": "world"
///                        }
///                        """)
/// }
/// ```
///
/// The `Server` can be started asynchronously by calling `start()` and stopped by calling `stop()`:
///
/// ```
/// try server.start()
/// try server.stop()
/// ```
///
/// The `Server` can also be started synchronously using `syncStart()`
/// if you want to block the current thread:
///
/// ```
/// try server.syncStart()
/// ```
public final class Server {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let router = Router()
    private let logger: LoggerType
    private let requestHandler: RequestHandler
    private let host = "localhost"
    private let port: Int
    private var isRunning = false

    init(port: Int, logger: LoggerType) {
        self.port = port
        self.logger = logger
        self.requestHandler = RequestHandler(router: router, logger: logger)
    }

    /// Creates an instance of an `HTTP` `Server`.
    /// - Parameters:
    ///   - port: The port to bind to. Defaults to `8888`.
    ///   - isLoggingEnabled: Enables logging to `stdout`. Defaults to `false`.
    public convenience init(port: Int = 8888, isLoggingEnabled: Bool = false) {
        self.init(port: port, logger: Logger(isEnabled: isLoggingEnabled))
    }
}

public extension Server {
    /// Starts the `Server` asynchronously.
    func start() throws {
        guard isRunning == false else { return }
        isRunning = true
        try startChannel()
    }

    /// Starts the `Server` synchronously.
    ///
    /// Use this if you want to block the current thread.
    func syncStart() throws {
        guard isRunning == false else { return }
        isRunning = true
        try startChannel().closeFuture.wait()
    }

    /// Stops the server and closes all connections gracefully.
    func stop() throws {
        guard isRunning else { return }
        isRunning = false
        try group.syncShutdownGracefully()
        logger.log(title: "Hearken", content: "Server was shut down gracefully")
    }

    /// A custom subscript to assign routes to the `Server` with a closure that returns an `HTTPResponse`.
    ///
    /// Enables the following API:
    /// ```
    /// server[.POST, "/api/hello"] = { request in
    ///     print(request)
    ///
    ///     return .init(status: .ok,
    ///                  headers: [.contentType(.json)],
    ///                  body: """
    ///                        {
    ///                            "hello": "world"
    ///                        }
    ///                        """)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - method: `HTTP` method eg. `POST`.
    ///   - uri: `HTTP` `URI` eg. `/api/test`.
    subscript(_ method: HTTPMethod, _ uri: String) -> ((HTTPRequest) -> HTTPResponse)? {
        get { router.routes[.init(method: method, uri: uri)] }
        set { router.routes[.init(method: method, uri: uri)] = newValue }
    }

    /// A custom subscript to assign routes to the `Server` with just an `HTTPResponse`.
    ///
    /// Enables the following API:
    /// ```
    /// server[.GET, "/api/health"] = HTTPResponse(status: .ok)
    /// ```
    ///
    /// - Parameters:
    ///   - method: `HTTP` method eg. `POST`.
    ///   - uri: `HTTP` `URI` eg. `/api/test`.
    subscript(_ method: HTTPMethod, _ uri: String) -> HTTPResponse? {
        get { nil }
        set { router.routes[.init(method: method, uri: uri)] = newValue.map { newValue in { _ in newValue } } }
    }
}

private extension Server {
    @discardableResult
    func startChannel() throws -> Channel {
        let channel = try ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline()
                    .flatMap { channel.pipeline.addHandler(self.requestHandler) }
            }.childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
            .bind(host: host, port: port)
            .wait()

        logger.log(title: "Hearken", content: "Server running on \(host):\(port)")

        return channel
    }
}
