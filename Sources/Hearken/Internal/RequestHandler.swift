import NIO
import NIOHTTP1

final class RequestHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    private let router: Router
    private let logger: LoggerType
    private var requestBuffer: [HTTPServerRequestPart] = []

    init(router: Router, logger: LoggerType) {
        self.router = router
        self.logger = logger
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let latestPart = unwrapInboundIn(data)
        requestBuffer.append(latestPart)

        guard case .end = latestPart else { return }

        guard let request = readRequest(),
            let response = router.route(request: request) else {
                write(context: context, response: .init(status: .notFound))
                return
        }

        write(context: context, response: response)
    }
}

private extension RequestHandler {
    func readRequest() -> HTTPRequest? {
        guard case .head(let head) = requestBuffer.first else { return nil }

        var body = HTTPBody()

        requestBuffer.compactMap { part -> ByteBuffer? in
            if case .body(let buffer) = part { return buffer }
            return nil
        }.forEach { body.append(contentsOf: $0.readableBytesView) }

        requestBuffer.removeAll()

        logRequest(head: head, body: body)

        return .init(method: head.method,
                     uri: head.uri,
                     headers: head.headers,
                     body: body)
    }

    func write(context: ChannelHandlerContext, response: HTTPResponse) {
        var headers = response.headers
        headers.add(.contentLength(response.body?.count ?? .zero))

        let head = HTTPResponseHead(version: .init(major: 1, minor: 1),
                                    status: response.status,
                                    headers: headers)
        context.write(wrapOutboundOut(.head(head)), promise: nil)

        if let body = response.body {
            var buffer = context.channel.allocator.buffer(capacity: body.count)
            buffer.writeBytes(body)
            context.write(wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
        }

        context.writeAndFlush(wrapOutboundOut(.end(nil)), promise: nil)

        logResponse(head: head, body: response.body)
    }
}

private extension RequestHandler {
    func logRequest(head: HTTPRequestHead, body: HTTPBody) {
        logger.log(title: "Request", content:
            """
            \(head.method.rawValue) \(head.uri) \(head.version)
            \(head.headers.logDescription)

            \(body.utf8String)
            """
        )
    }

    func logResponse(head: HTTPResponseHead, body: HTTPBody?) {
        logger.log(title: "Response", content:
            """
            \(head.version) \(head.status.code)
            \(head.headers.logDescription)

            \(body?.utf8String ?? "")
            """
        )
    }
}
